import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  const now = new Date().toISOString();
  
  // 1. Fetch expired statuses
  const { data: expiredStatuses, error: fetchError } = await supabase
    .from('statuses')
    .select('storagePath')
    .lt('expiresAt', now);

  if (fetchError) {
    return new Response(JSON.stringify({ error: fetchError.message }), { status: 500 });
  }

  // 2. Delete images from Storage
  if (expiredStatuses && expiredStatuses.length > 0) {
    const paths = expiredStatuses.map(s => s.storagePath).filter(p => p !== null && p !== '');
    if (paths.length > 0) {
        await supabase.storage.from('chatapp').remove(paths);
    }
  }

  // 3. Delete status documents
  await supabase
    .from('statuses')
    .delete()
    .lt('expiresAt', now);

  return new Response(JSON.stringify({ success: true, count: expiredStatuses?.length }), {
    headers: { "Content-Type": "application/json" },
  });
});
