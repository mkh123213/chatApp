/// <reference types="https://esm.sh/@supabase/functions-js/src/edge-runtime.d.ts" />
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

function base64url(data: Uint8Array): string {
  return btoa(String.fromCharCode(...data))
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/, "");
}

function base64urlEncode(str: string): string {
  return base64url(new TextEncoder().encode(str));
}

async function getAccessToken(): Promise<string> {
  const clientEmail = Deno.env.get("FCM_CLIENT_EMAIL")!;
  const privateKeyPem = Deno.env.get("FCM_PRIVATE_KEY")!.replace(/\\n/g, "\n");
  const now = Math.floor(Date.now() / 1000);

  const header = base64urlEncode(JSON.stringify({ alg: "RS256", typ: "JWT" }));
  const payload = base64urlEncode(
    JSON.stringify({
      iss: clientEmail,
      scope: "https://www.googleapis.com/auth/cloud-platform",
      aud: "https://oauth2.googleapis.com/token",
      iat: now,
      exp: now + 3600,
    })
  );

  const pemBody = privateKeyPem
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replace(/\s/g, "");
  const keyBytes = Uint8Array.from(atob(pemBody), (c) => c.charCodeAt(0));

  const cryptoKey = await crypto.subtle.importKey(
    "pkcs8",
    keyBytes,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"]
  );

  const signInput = new TextEncoder().encode(`${header}.${payload}`);
  const signature = new Uint8Array(
    await crypto.subtle.sign("RSASSA-PKCS1-v1_5", cryptoKey, signInput)
  );

  const jwt = `${header}.${payload}.${base64url(signature)}`;

  const tokenResponse = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });

  const tokenData = await tokenResponse.json();
  if (!tokenResponse.ok) {
    throw new Error(`Token error: ${JSON.stringify(tokenData)}`);
  }
  return tokenData.access_token;
}

serve(async (req: Request) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  try {
    const { token, title, body, data, dataOnly } = await req.json();

    if (!token) {
      return new Response(JSON.stringify({ error: "token is required" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    const accessToken = await getAccessToken();
    const projectId = Deno.env.get("FCM_PROJECT_ID")!;

    const message: Record<string, unknown> = {
      token,
      data: data ?? {},
      android: dataOnly
        ? { priority: "high" }
        : {
            notification: {
              sound: "default",
              channel_id: "high_importance_channel",
            },
          },
      apns: dataOnly
        ? {
            payload: { aps: { "content-available": 1 } },
            headers: { "apns-priority": "10" },
          }
        : {
            payload: { aps: { sound: "default", "content-available": 1 } },
          },
    };

    if (!dataOnly && title) {
      message.notification = { title, body: body ?? "" };
    }

    const fcmUrl = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;

    const response = await fetch(fcmUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${accessToken}`,
      },
      body: JSON.stringify({ message }),
    });

    const result = await response.json();

    if (!response.ok) {
      console.error("FCM error:", result);
      return new Response(JSON.stringify({ error: result }), {
        status: response.status,
        headers: { "Content-Type": "application/json" },
      });
    }

    return new Response(JSON.stringify({ success: true }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (e) {
    console.error("Error:", e);
    return new Response(JSON.stringify({ error: (e as Error).message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
