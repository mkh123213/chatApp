import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import {
  RtcTokenBuilder,
  RtcRole,
} from "npm:agora-token@2.0.3";

const APP_ID = Deno.env.get("AGORA_APP_ID")!;
const APP_CERTIFICATE = Deno.env.get("AGORA_APP_CERTIFICATE")!;
const TOKEN_EXPIRY_SECONDS = 3600;

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  try {
    const { channelName, uid, role } = await req.json();

    if (!channelName) {
      return new Response(
        JSON.stringify({ error: "channelName is required" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    const tokenRole =
      role === "subscriber" ? RtcRole.SUBSCRIBER : RtcRole.PUBLISHER;
    const userUid = uid ?? 0;
    const expireTime = Math.floor(Date.now() / 1000) + TOKEN_EXPIRY_SECONDS;

    const token = RtcTokenBuilder.buildTokenWithUid(
      APP_ID,
      APP_CERTIFICATE,
      channelName,
      userUid,
      tokenRole,
      expireTime,
      expireTime
    );

    return new Response(
      JSON.stringify({ token, appId: APP_ID, expiresIn: TOKEN_EXPIRY_SECONDS }),
      { headers: { "Content-Type": "application/json" } }
    );
  } catch (e) {
    console.error("Error:", e);
    return new Response(
      JSON.stringify({ error: (e as Error).message }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});
