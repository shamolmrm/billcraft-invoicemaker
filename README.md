# BillCraft — Professional Invoice Maker

A cross-platform Flutter app for creating, managing, and tracking invoices and estimates — built for freelancers and small businesses.

## Features

- Create and customize invoices & estimates with multiple templates
- Client management
- Item/product catalog
- Reports and dashboard overview
- Multi-language support
- Onboarding flow and account settings

## Tech Stack

- **Flutter / Dart**
- Provider-based state management
- Repository pattern for data access

## Project Structure

```
billcraft/            # Flutter app source
├── lib/
│   ├── core/           # constants, routes, theme, utils
│   ├── models/
│   ├── providers/
│   ├── repositories/
│   ├── screens/         # auth, dashboard, invoices, estimates, clients, items, reports, settings...
│   ├── services/
│   └── widgets/         # buttons, cards, inputs, invoice templates, loaders
Draft image/           # Design/marketing reference images
```

## Getting Started

```bash
cd billcraft
flutter pub get
flutter run
```
