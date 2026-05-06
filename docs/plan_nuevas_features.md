# Plan de nuevas features — Finanzapp

> Plan estructural (no implementacional) para incorporar 5 features al sistema. No incluye código; sirve como guía de decisión sobre **qué hacer primero, dónde vive cada cosa y qué decisiones tomar antes de tocar nada**.

---

## Principio rector: minimizar el rework

El sistema vive en **3 plataformas** (web, iOS, Android) que **comparten el mismo backend Supabase**. Esto significa que cualquier cambio en datos = trabajo en 3 lugares.

Cada feature cae en una de dos categorías:

- **Cambios de modelo de datos** (tocan Supabase + web + móvil): features 1, 3, 4, 5.
- **Tooling puro** (no cambia el modelo): feature 2.

**Implicancia clave:** la feature 2 (import/export) **conviene hacerla al final**, cuando el modelo de datos esté estable. Si se hace ahora, hay que migrar el formato JSON cada vez que se agregue algo nuevo.

---

## Análisis individual

### Feature 3 — Cargar sueldo (income)

**Valor del producto:** **muy alto**. Cambia la pregunta que responde la app de *"¿cuánto debo este mes?"* a *"¿cuánto me queda este mes después de pagar todo?"*. Es un salto cualitativo, no incremental.

**Dónde vive:**
- **Backend:** nueva tabla `incomes` (o "ingresos"). Estructura parecida a la de gastos recurrentes: nombre, monto, día del mes, tipo (sueldo / freelance / otro), si es recurrente o de una sola vez.
- **Móvil/Web:** una nueva sección en Configuración ("Ingresos"), simétrica a "Gastos recurrentes". Y en la pantalla del Mes, el resumen pasa a mostrar **3 números**: ingresos del mes, gastos del mes, saldo.

**Decisiones a tomar antes:**
- ¿Un solo sueldo o múltiples ingresos? Recomendado: soportar múltiples desde el principio (alguien puede tener sueldo + alquiler que cobra + freelance).
- ¿El saldo es información solamente, o dispara alertas si se va a negativo? Para v1, solo mostrarlo.

**Esfuerzo:** medio. Es trabajo sólido pero la lógica copia mucho de gastos recurrentes.

---

### Feature 4 — Gasto puntual del mes en curso

**Valor del producto:** alto, baja inversión. Es un agujero real (hoy no se puede cargar "este mes me compro un sillón al contado") y la solución es chica.

**Dónde vive:**
- **Backend:** dos opciones:
  - **Opción A (simple, recomendada):** sumar al modelo de gastos recurrentes un campo `applies_to_month` opcional. Si está vacío, es recurrente (como hoy). Si tiene un mes específico, aparece solo ese mes.
  - **Opción B:** una tabla nueva `one_time_expenses`. Más limpia conceptualmente pero duplica código de gastos.
- **Móvil/Web:** en el formulario de "Nuevo gasto" agregar un toggle: *"¿Es solo para este mes?"*. Y en la pantalla del Mes, mostrarlos junto con el resto pero con un indicador sutil ("una sola vez").

**Decisión a tomar antes:** A o B. Recomendación: **A**, porque desde la perspectiva del usuario "gasto puntual" y "gasto recurrente" son la misma idea con distinta repetición.

**Esfuerzo:** bajo.

---

### Feature 1 — Monedas

Esta es la más espinosa. Hay **dos escenarios distintos** que la gente confunde:

**Escenario A — Una moneda por usuario (locale)**
Cada cuenta elige su moneda (ARS, USD, EUR, etc.) y todos sus registros usan esa moneda. Útil para expandir a otros países.

**Escenario B — Multi-moneda real (mezcla)**
Cada gasto/ingreso puede estar en una moneda distinta. Ejemplo típico Argentina: alquiler en ARS, Netflix en USD, sueldo en ARS, freelance en USD. La app convierte a una moneda principal para mostrar totales.

**Diferencia de esfuerzo:** A es chico (un campo en `users`). B es grande:
- Necesita cotización (¿oficial, blue, MEP?).
- Necesita historial de cotizaciones (un gasto de marzo no se convierte con la cotización de hoy).
- Necesita un campo de moneda en CADA registro de plata.

**Recomendación:**
- **Si el mercado objetivo sigue siendo Argentina:** hacer el Escenario A primero (cuesta poco) y agregar Escenario B **solo cuando** lo pidan usuarios reales.
- **Si se quiere vender afuera:** Escenario A es obligatorio antes del lanzamiento internacional. B puede esperar.

**Dónde vive (Escenario A):**
- **Backend:** un campo `currency` en la tabla del usuario, con default `ARS`.
- **Móvil/Web:** en Configuración, un selector de moneda. En toda la app, los formatos de número leen ese setting.

---

### Feature 2 — Import / Export JSON

**Valor del producto:** medio. Útil para backups, migración entre cuentas, y para cargar datos rápido desde otra fuente (planilla, otra app). No es una feature "estrella", pero la gente meticulosa la valora mucho.

**Dónde vive:**
- **Backend:** ningún cambio de modelo. Solo lógica para leer/escribir el contenido de las tablas del usuario.
- **Web:** sección en Configuración → "Exportar datos" (descarga un .json) y "Importar datos" (sube un .json).
- **Móvil:** mismo lugar pero con el selector de archivos del sistema.

**Decisiones a tomar antes:**
- **¿Qué pasa al importar?** ¿Reemplaza todo, o se merge con lo existente? Mezclar es engañoso (¿qué hacer con duplicados?). Lo más sano: *"Importar reemplaza todos los datos actuales — exportá antes para backup."*
- **¿Versionado del schema?** Sí: el JSON debe tener un campo `version: 1`. Cuando cambie el modelo en el futuro, se pueden migrar JSONs viejos al nuevo formato.
- **Datos sensibles:** asegurarse de que el JSON no incluya nada del backend que no debería salir (claves, IDs internos, etc.).

**Por qué hacerla al final:** si se hace ahora, cada vez que se sume una feature (sueldo, monedas, etc.) hay que actualizar el formato. Hacerla al final = un solo formato estable.

---

### Feature 5 — Tarjeta de crédito vs débito

**Valor del producto:** **bajo**.

- Una tarjeta de débito **descuenta al toque del banco** → no hay "cuota" ni "vencimiento".
- En este tipo de app, las compras con débito son indistinguibles de un gasto en efectivo.
- Si se cargaran como "tarjeta de débito", solo servirían como **etiqueta de origen** del gasto, no para planificar.

**Sugerencia:** **no hacerla ahora.** Es ruido. Si en el futuro algún usuario lo pide con un caso de uso claro (ej: "quiero ver mis gastos por tarjeta para reclamar promociones"), agregarla.

**Si igual se quiere hacer:**
- **Backend:** un campo `type` en `cards` (`credit` | `debit`).
- **UI:** en débito ocultar secciones de cuotas y vencimiento.

**Esfuerzo:** bajo.

---

## Orden recomendado

| Fase | Feature | Por qué en este orden |
|------|---------|----------------------|
| **1** | **#4 Gasto puntual** | Esfuerzo mínimo, agujero real, no afecta al resto |
| **2** | **#3 Sueldo / ingresos** | Mayor salto de valor del producto. Antes que monedas para no rehacer la UI dos veces |
| **3** | **#1 Monedas (Escenario A)** | Solo si se va a expandir fuera de Argentina o se quiere hacerlo "bien" antes de que crezca la base de datos |
| **4** | **#2 Import / Export** | Al final, con el schema estable |
| **5** | **#5 Débito vs crédito** | Solo si aparece demanda real |

**Atajo conservador:** 4 → 3 → 2, saltear 1 (mientras sea Argentina) y 5 (mientras nadie lo pida). Tres fases, alto impacto.

---

## Cómo abordar cada fase

Recomendación de proceso para cada feature, en orden:

1. **Diseño en Supabase primero.** El schema es el contrato. Decidirlo y migrarlo en Supabase.
2. **Web segundo.** Es más rápido iterar y ajustar la UX en web (sin compilaciones de iOS, sin store reviews).
3. **Móvil tercero.** Una vez que el flujo está validado en web, replicarlo en Flutter.
4. **Una feature por vez.** Mergear y publicar antes de empezar la siguiente — así llegan errores y feedback temprano.

---

## Lo que se deja afuera a propósito

- **Categorías personalizadas de gastos.** Hoy ya hay tipos predefinidos. Permitir que el usuario agregue propios es otra mini-feature.
- **Reportes anuales / gráficos.** Una vez que haya ingresos + gastos, abre la puerta a "tu año en gráficos". Dejarlo para una **fase 5** opcional.
- **Compartir cuenta entre dos usuarios** (parejas). Frecuente pedido en apps de finanzas, pero es una feature gigante.

---

## Resumen ejecutivo

- **Empezar por la #4** (gasto puntual): chica, valiosa, ideal para validar el flujo schema → web → móvil.
- **Seguir con la #3** (sueldo): es la que más cambia el producto.
- **Después la #1** (monedas, escenario A) solo si hay plan de expansión fuera de Argentina.
- **#2** (import/export) al final, con el modelo estable.
- **#5** (débito) probablemente no haga falta nunca.
