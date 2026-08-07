import OpenAI from "openai";

const client = new OpenAI({
  baseURL: process.env.BASE_URL || "http://localhost:20138/v1",
  apiKey: process.env.API_KEY || "wqqx40CQxJL3hrLjraQ9LYUfMiz1SrxZHyhHARid",
});

const model = process.env.MODEL || "claude-sonnet-5";

async function main() {
  console.log(`Testing ${model} on ${client.baseURL}`);

  const res = await client.chat.completions.create({
    model,
    messages: [{ role: "user", content: "Say hi in 3 words" }],
  });

  console.log("Response:", res.choices[0].message.content);
  console.log("Model:", res.model);
  console.log("Tokens:", res.usage);
}

main().catch(console.error);
