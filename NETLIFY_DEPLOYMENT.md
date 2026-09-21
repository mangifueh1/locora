# Deploy Locora to Netlify

This project is a Flutter web application. Netlify hosts the compiled static files in `build/web`; it does not host the Flutter API or Socket.IO server.

## Before you deploy

You need:

- Flutter installed locally, with web support enabled.
- A deployed HTTPS API server. The current default API URL is `http://localhost:4000`, which will not work for visitors after deployment.
- A public Mapbox access token.
- A Netlify account.

Verify Flutter web support from the project directory:

```powershell
flutter doctor
flutter devices
```

The output should include a web device such as Chrome or Edge.

## 1. Prepare the backend

Deploy the API and Socket.IO server separately, for example on Render, Railway, Fly.io, or another server host.

Your backend must:

1. Serve HTTPS traffic.
2. Allow requests from the Netlify domain with CORS.
3. Allow the Socket.IO/WebSocket origin from the Netlify domain.
4. Expose the same routes expected by the Flutter app.
5. Use a production Socket.IO URL that starts with `https://` or `wss://`, depending on how the client constructs its URL.

After deployment, record the API base URL, for example:

```text
https://api.example.com
```

Do not use a trailing slash if the application appends paths directly to the base URL.

## 2. Configure the Mapbox token

Create or select a public Mapbox token. Restrict it to your production Netlify hostname in the Mapbox token settings, such as:

```text
https://locora.netlify.app/*
```

A browser application cannot keep a Mapbox public token secret. Domain restrictions and Mapbox usage limits are the protection you need.

## 3. Build the Flutter web app

From the project root, run:

```powershell
flutter pub get
flutter build web --release `
  --dart-define=API_BASE_URL=https://api.example.com `
  --dart-define=MAPBOX_TOKEN=pk.your_public_mapbox_token
```

PowerShell uses the backtick for line continuation. You can also run the command on one line:

```powershell
flutter build web --release --dart-define=API_BASE_URL=https://api.example.com --dart-define=MAPBOX_TOKEN=pk.your_public_mapbox_token
```

The compiled website will be in:

```text
build/web
```

Important: `String.fromEnvironment` values are compile-time values. Adding environment variables in Netlify without passing them to `flutter build web` does not change the already-built application.

## 4. Add the SPA redirect

Flutter uses client-side routing. Netlify must send unknown routes back to `index.html` so refreshing a route does not return a 404.

Create this file:

```text
build/web/_redirects
```

Add exactly:

```text
/* /index.html 200
```

If you deploy from a Git repository, put the redirect in the repository instead:

```text
web/_redirects
```

Flutter copies files from `web/` into the generated web output.

## 5. Deploy the compiled files

### Option A: Netlify web dashboard

1. Open [Netlify](https://app.netlify.com/) and sign in.
2. Select **Add new project** and choose **Deploy manually**.
3. Drag the project’s `build/web` folder into the deployment area.
4. Open the generated Netlify URL.
5. Test a deep link by opening a route directly and refreshing the page.

This is the quickest deployment method. Rebuild and upload `build/web` again whenever the Flutter source changes.

### Option B: Netlify CLI

Install and authenticate the Netlify CLI:

```powershell
npm install -g netlify-cli
netlify login
```

From the project root, create or link a Netlify site:

```powershell
netlify init
```

Choose **Create & configure a new site** or link an existing site. Then deploy the already-built output:

```powershell
netlify deploy --dir=build/web --prod
```

## 6. Git-based continuous deployment

Netlify can build this project on every push, but the build image must install Flutter first. Configure these values in **Site configuration > Build & deploy > Continuous deployment**:

```text
Base directory: /
Publish directory: build/web
```

Use this as the build command:

```bash
if [ ! -d "$HOME/flutter" ]; then git clone https://github.com/flutter/flutter.git --depth 1 --branch stable "$HOME/flutter"; fi; export PATH="$HOME/flutter/bin:$PATH"; flutter config --no-analytics; flutter pub get; flutter build web --release --dart-define=API_BASE_URL="$API_BASE_URL" --dart-define=MAPBOX_TOKEN="$MAPBOX_TOKEN"
```

Add these Netlify environment variables under **Site configuration > Environment variables**:

```text
API_BASE_URL=https://api.example.com
MAPBOX_TOKEN=pk.your_public_mapbox_token
```

For a repeatable Git deployment, add a `netlify.toml` file at the repository root:

```toml
[build]
  publish = "build/web"
  command = "if [ ! -d \"$HOME/flutter\" ]; then git clone https://github.com/flutter/flutter.git --depth 1 --branch stable \"$HOME/flutter\"; fi; export PATH=\"$HOME/flutter/bin:$PATH\"; flutter config --no-analytics; flutter pub get; flutter build web --release --dart-define=API_BASE_URL=\"$API_BASE_URL\" --dart-define=MAPBOX_TOKEN=\"$MAPBOX_TOKEN\""
```

Then connect the repository in Netlify and deploy the branch you choose.

## 7. Configure the production domain

After the first successful deploy:

1. Open **Domain management** in Netlify.
2. Add your custom domain, if you have one.
3. Update the Mapbox token URL restriction to include the final domain.
4. Update backend CORS and Socket.IO allowed origins to include the final domain.
5. Rebuild the Flutter app if `API_BASE_URL` or `MAPBOX_TOKEN` changed.

## 8. Verify the deployment

Open the site in a private browser window and check:

- The home page loads without a blank screen.
- Browser DevTools has no failed JavaScript or asset requests.
- Login and signup requests go to the production API, not `localhost:4000`.
- Map screens render and accept gestures.
- Socket.IO/live delivery features connect successfully.
- Refreshing a nested route still loads the application.
- Browser location permission works if the feature requests it.

## Mapbox web note

This project uses `mapbox_maps_flutter: ^3.0.0-alpha.31`. The v3 line provides Flutter web support as a prerelease/public preview. Test every map screen in the production browser build. If the web build fails around `MapWidget`, keep the native Mapbox implementation for Android/iOS and add a web-specific map implementation, such as Mapbox GL JS or another Flutter web-compatible map package.

## Recommended first deployment

For the first release, use this sequence:

```powershell
flutter pub get
flutter build web --release --dart-define=API_BASE_URL=https://api.example.com --dart-define=MAPBOX_TOKEN=pk.your_public_mapbox_token
```

Add `build/web/_redirects`, upload `build/web` to Netlify, then test the production API, maps, authentication, and live updates before enabling Git-based automatic deploys.
