# THE MEMORIES — Next.js starter

A responsive Next.js starter for a personal memory archive, designed for phones, tablets, laptops and larger screens.

## Included
- Next.js + TypeScript
- Responsive dark editorial design
- Email/password sign-up and sign-in through Supabase
- Friends Memories and private-by-default Admiring Her collections
- Photo/video uploads to a private Supabase Storage bucket
- Signed media URLs
- Live refresh through Supabase Realtime
- SQL schema with Row Level Security policies
- Vercel deployment-ready structure

## Important feature boundaries
This is a working foundation, not a finished production social platform.
- The invitation acceptance flow and email delivery are not implemented yet. Do not promise invited-user access until a secure server-side invitation flow is added.
- The current app allows authenticated users to create memories. Friends Memories are visible to authenticated users; private Admiring Her memories are visible only to their owner or users granted access in `memory_access`.
- The owner-only admin dashboard, approval workflow for community contributions, Live Photo paired-asset handling, audio memories, and advanced TV remote navigation are not implemented in this starter.
- A blurred preview is not a security boundary. Private media must remain in a private bucket and be served only after authorization.
- For production, add rate limits, email verification, server-side invitation tokens, file scanning/validation, and backups.

## 1. Create Supabase
1. Create a project at https://supabase.com.
2. Open SQL Editor.
3. Run all of `supabase/schema.sql`.
4. In Project Settings → API, copy the Project URL and publishable key.
5. In Authentication → URL Configuration, add your deployed Vercel URL to the allowed redirect URLs.

## 2. Configure locally
1. Copy `.env.example` to `.env.local`.
2. Fill in the Supabase URL and publishable key.
3. Never put a Supabase service-role key in a `NEXT_PUBLIC_` variable or browser code.

## 3. Run on a computer or cloud development environment
```bash
npm install
npm run dev
```
Open http://localhost:3000.

## 4. Publish with Vercel
1. Push this folder to a private GitHub repository.
2. Import that repository at https://vercel.com.
3. Add the two environment variables from `.env.example` in Vercel → Project Settings → Environment Variables.
4. Deploy.
5. Add the final Vercel URL to Supabase Authentication → URL Configuration.
6. Redeploy after changing environment variables.

## iPhone note
You can manage GitHub, Supabase and Vercel in Safari on iPhone. Editing a full Next.js project is easier in a browser-based coding environment or on a computer, but this ZIP contains the project files.
