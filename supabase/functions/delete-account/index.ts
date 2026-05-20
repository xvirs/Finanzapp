// Edge Function: delete-account
//
// Borra la cuenta del usuario autenticado. Requerido por Apple App Review
// Guideline 5.1.1(v) — Data Collection and Storage (rechazo 2026-05-18).
//
// Flujo:
//   1. Lee el JWT del header Authorization → identifica al user actual.
//   2. Usa el service role key (inyectado por Supabase en el runtime) para
//      llamar auth.admin.deleteUser(userId). El client SDK no puede hacer
//      esto porque auth.users no tiene RLS abierta para los users.
//   3. Postgres ejecuta ON DELETE CASCADE en bills, credit_cards, incomes,
//      installment_purchases y payments — todas las FKs apuntan a
//      auth.users(id) ON DELETE CASCADE, así que no hay que borrar manual.
//
// Variables de entorno (auto-inyectadas por Supabase, no setear):
//   - SUPABASE_URL
//   - SUPABASE_ANON_KEY
//   - SUPABASE_SERVICE_ROLE_KEY
//
// Deploy: supabase functions deploy delete-account

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.45.4';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (req.method !== 'POST') {
    return json({ error: 'Method not allowed' }, 405);
  }

  const authHeader = req.headers.get('Authorization');
  if (!authHeader) {
    return json({ error: 'Missing authorization header' }, 401);
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
  const anonKey = Deno.env.get('SUPABASE_ANON_KEY') ?? '';
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';

  // Cliente con el JWT del user para validar identidad.
  const userClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
  });

  const { data: userData, error: userError } = await userClient.auth.getUser();
  if (userError || !userData?.user) {
    return json({ error: 'Invalid or expired token' }, 401);
  }

  const userId = userData.user.id;

  // Cliente admin con service role para poder borrar de auth.users.
  const adminClient = createClient(supabaseUrl, serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });

  const { error: deleteError } = await adminClient.auth.admin.deleteUser(userId);
  if (deleteError) {
    console.error('Failed to delete user', userId, deleteError);
    return json({ error: deleteError.message }, 500);
  }

  return json({ success: true, userId }, 200);
});

function json(body: Record<string, unknown>, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}
