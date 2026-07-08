# Migración one-time (ya aplicada al Runner.xcodeproj commiteado): agrega el
# target de la extensión WidgetKit "FinanzappWidget" al proyecto. Es idempotente
# (aborta si el target ya existe). Correr desde ios/:  ruby scripts/add_widget_target.rb
#
# GOTCHA: la fase "Embed App Extensions" se mueve ANTES de "Thin Binary" para
# evitar el error "Cycle inside Runner" (lo dispara ExtractAppIntentsMetadata de
# Xcode 15+ cuando la extensión se embebe después del Thin Binary de Flutter).
require "xcodeproj"

PROJECT = "Runner.xcodeproj"
WIDGET_NAME = "FinanzappWidget"
WIDGET_BUNDLE_ID = "app.finanzapp.client.FinanzappWidget"
TEAM = "SJVXS34P6P"
WIDGET_PROFILE = "Finanzapp Widget App Store"

project = Xcodeproj::Project.open(PROJECT)

if project.targets.any? { |t| t.name == WIDGET_NAME }
  puts "Target #{WIDGET_NAME} ya existe — abortando para no duplicar."
  exit 0
end

runner = project.targets.find { |t| t.name == "Runner" }
raise "No encontré el target Runner" unless runner

# --- Referencia a Generated.xcconfig (da FLUTTER_BUILD_NAME/NUMBER) ---
flutter_group = project.main_group.children.find { |c| c.respond_to?(:display_name) && c.display_name == "Flutter" }
gen_ref = project.files.find { |f| f.path && f.path.end_with?("Generated.xcconfig") }
if gen_ref.nil?
  gen_ref = flutter_group.new_file("Generated.xcconfig")
end
puts "Generated.xcconfig ref: #{gen_ref.path}"

# --- Nuevo target: App Extension (WidgetKit) ---
widget = project.new_target(:app_extension, WIDGET_NAME, :ios, "15.0")
puts "Target creado: #{widget.name} (#{widget.product_type})"

# --- Grupo + archivos del widget en el navegador ---
group = project.main_group.new_group(WIDGET_NAME, WIDGET_NAME)
swift_ref = group.new_file("#{WIDGET_NAME}.swift")
group.new_file("Info.plist")
group.new_file("#{WIDGET_NAME}.entitlements")

# Fuente al build phase de Sources
widget.source_build_phase.add_file_reference(swift_ref)

# --- Build settings comunes a Debug y Release ---
common = {
  "PRODUCT_BUNDLE_IDENTIFIER"    => WIDGET_BUNDLE_ID,
  "PRODUCT_NAME"                 => "$(TARGET_NAME)",
  "INFOPLIST_FILE"               => "#{WIDGET_NAME}/Info.plist",
  "CODE_SIGN_ENTITLEMENTS"       => "#{WIDGET_NAME}/#{WIDGET_NAME}.entitlements",
  "IPHONEOS_DEPLOYMENT_TARGET"   => "15.0",
  "SWIFT_VERSION"                => "5.0",
  "TARGETED_DEVICE_FAMILY"       => "1,2",
  "DEVELOPMENT_TEAM"             => TEAM,
  "GENERATE_INFOPLIST_FILE"      => "NO",
  "SKIP_INSTALL"                 => "YES",
  "CLANG_ENABLE_MODULES"         => "YES",
  "SWIFT_EMIT_LOC_STRINGS"       => "YES",
  "LD_RUNPATH_SEARCH_PATHS"      => ["$(inherited)", "@executable_path/Frameworks", "@executable_path/../../Frameworks"],
}

widget.build_configurations.each do |cfg|
  # Base config = Generated.xcconfig → hereda FLUTTER_BUILD_NAME/NUMBER
  cfg.base_configuration_reference = gen_ref
  common.each { |k, v| cfg.build_settings[k] = v }
  if cfg.name == "Release"
    cfg.build_settings["CODE_SIGN_STYLE"] = "Manual"
    cfg.build_settings["CODE_SIGN_IDENTITY"] = "Apple Distribution"
    cfg.build_settings["PROVISIONING_PROFILE_SPECIFIER"] = WIDGET_PROFILE
  else
    cfg.build_settings["CODE_SIGN_STYLE"] = "Automatic"
  end
end

# --- Dependencia + embebido en el app ---
runner.add_dependency(widget)

embed_phase = runner.build_phases.find do |ph|
  ph.respond_to?(:symbol_dst_subfolder_spec) && ph.symbol_dst_subfolder_spec == :plug_ins && ph.display_name == "Embed App Extensions"
end
if embed_phase.nil?
  embed_phase = runner.new_copy_files_build_phase("Embed App Extensions")
  embed_phase.symbol_dst_subfolder_spec = :plug_ins
end
appex_ref = widget.product_reference
build_file = embed_phase.add_file_reference(appex_ref)
build_file.settings = { "ATTRIBUTES" => ["RemoveHeadersOnCopy"] }

# Asegurar que el embed corra después de compilar la extensión: mover el
# Embed phase al final (después de las fases de compilación del Runner).
runner.build_phases.delete(embed_phase)
runner.build_phases << embed_phase

project.save
puts "OK — proyecto guardado."
puts "Targets ahora: #{project.targets.map(&:name).join(', ')}"
