# App captures

## Route planner

Captured on November 27, 2026, from the running Android debug build on a Pixel 8 emulator with Android 17. The planner uses the sample stops bundled with the app.

- `optimize-route.gif` shows the **Optimize route** tap, the updated map, and the change from 7.3 km to 4.0 km. The last frame holds for three extra seconds so readers can inspect the result.
- `route-draft.png` shows the original visit order.
- `route-optimized.png` shows the shorter visit order with its leg distances.
- `route-stop-picker.png` shows the six sample shops and the three selected stops.

## Historical scaffold captures

The PNG and GIF show the unmodified `MyApp` from `lib/main.dart`, rendered at a 390 × 844 logical-pixel surface by Flutter's widget-test harness on 12 November 2026. The GIF joins counter states zero and one; its timing is edited. These are widget renders, not physical-device screenshots or a route-planning demo.

The capture harness loads the SDK's Roboto and Material Icons fonts, renders the existing widget, taps its increment button and exports the two frames. No application feature or design was added for the captures.

Source SHA-256 for `lib/main.dart`: `525df2a854f3c54c831302c89f3089afd991cd03900c207e261d821bdc9ec656`.
