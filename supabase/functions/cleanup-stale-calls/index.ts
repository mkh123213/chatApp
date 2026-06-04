import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// This function is intended to be triggered by a Supabase cron job.
// It cleans up calls that have been stuck in 'ringing' (>60s) or 'accepted' (>24h).

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  const now = new Date();
  
  // 1. Delete calls stuck in 'ringing' for > 60 seconds
  const ringingCutoff = new Date(now.getTime() - 60 * 1000);
  await supabase
    .from('calls')
    .delete()
    .eq('status', 'ringing')
    .lt('createdAt', ringingCutoff.toISOString());

  // 2. Delete calls stuck in 'accepted' for > 24 hours
  const acceptedCutoff = new Date(now.getTime() - 24 * 60 * 60 * 1000);
  await supabase
    .from('calls')
    .delete()
    .eq('status', 'accepted')
    .lt('acceptedAt', acceptedCutoff.toISOString());

  return new Response(JSON.stringify({ success: true }), {
    headers: { "Content-Type": "application/json" },
  });
});
