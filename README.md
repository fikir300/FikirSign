# FikrSign 🤟

### Communication for Everyone

Fikr Sign is a mobile application designed to improve communication between deaf and hearing people through **Ethiopian Sign Language (EthSL)**. The platform aims to make communication more accessible through sign-to-text translation, text-to-sign communication, and sign language learning.

## The Problem

Communication between deaf and hearing people can be challenging when they do not share a common language. Access to Ethiopian Sign Language learning resources and accessible communication tools can also be limited.

Fikr Sign aims to reduce these barriers by providing a digital platform that supports sign language recognition, text-based communication, and learning resources.

The project focuses on **Ethiopian Sign Language**, not American Sign Language (ASL), and aims to promote inclusive communication through technology.

## Product Capabilities

- **Sign-to-Text:** Designed to recognize Ethiopian Sign Language signs and display their corresponding text.
- **Text-to-Sign:** Helps users communicate text through sign language demonstrations.
- **Learn Sign Language:** Provides learning resources for signs and common phrases.
- **Phrase-Based Learning:** Supports learning through individual signs and phrase demonstrations.
- **User Feedback:** Allows users to submit feedback to help improve translation quality and usability.
- **Accessible Interface:** Provides a user-friendly mobile experience.
- **Cloud Backend:** Connects the Flutter application to backend services hosted on AWS.
- **AI Integration:** Supports the integration of sign recognition and translation models as they become available.

*The availability of each capability depends on its implementation, testing, and integration status.*

## Technology

| Area | Technology |
|---|---|
| Client | Flutter / Dart |
| Backend | AWS Lambda |
| API Framework | Python / FastAPI |
| API Communication | REST API / HTTPS |
| Cloud Hosting | AWS Lambda Web Function or another configured AWS HTTPS endpoint |
| AI / Machine Learning | Sign recognition and translation components |
| Development Environment | Visual Studio Code |
| Version Control | Git / GitHub |
| UI/UX Design | Figma |

## Architecture

Fikr Sign is designed with separate components to support collaboration and independent development.

1. **Mobile Application:** Built with Flutter and Dart to provide the user interface and communication features.
2. **Cloud Backend:** Uses Python and FastAPI for backend API functionality, deployed through AWS Lambda.
3. **API Integration:** The mobile application communicates with the deployed backend through HTTPS requests.
4. **AI / Recognition Component:** Provides sign recognition and translation functionality as the relevant models and services are integrated.
5. **Feedback Component:** Supports collecting user feedback for future improvements.

## Documentation

Project documentation can include the following resources as they are developed:

- **Product Requirements:** Project goals, target users, features, and acceptance criteria.
- **Architecture:** Application structure and communication between Flutter, AWS Lambda, and recognition services.
- **API Documentation:** Available endpoints, request and response formats, and error handling.
- **Setup Guide:** Instructions for installing dependencies and configuring the application.
- **Testing Guide:** Instructions for testing API endpoints and mobile application features.
- **Deployment Guide:** Instructions for configuring and deploying the backend to AWS.

FastAPI's interactive API documentation may be available at `/docs` if it is enabled and exposed by the deployed backend.

## Quick Start

### Prerequisites

Install the following tools:

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Python](https://www.python.org/downloads/)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Git](https://git-scm.com/downloads)
- An AWS account with the necessary permissions to configure and deploy the backend

### 1. Clone the Repository

```bash
git clone 
cd FikirSign
```


### 2. Install Flutter Dependencies

Open a terminal in the Flutter application directory containing `pubspec.yaml`.

```bash
flutter pub get
```

### 3. Configure the AWS Backend Endpoint

Configure the Flutter application to use the deployed AWS HTTPS endpoint.

```dart
const String apiBaseUrl = 'https://lsx2aciyrr4b3q5tnrn4okeudu0gphwn.lambda-url.eu-north-1.on.aws/';
``

### 4. Deploy and Configure AWS Lambda

The backend is intended to run on AWS Lambda using Python and FastAPI.

1. Open the [AWS Management Console](https://console.aws.amazon.com/).
2. Navigate to AWS Lambda.
3. Open your Fikr Sign backend function or create the required function.
4. Configure the Python runtime, application code, and required dependencies.
5. Configure an HTTPS endpoint using the AWS hosting option selected for your project, such as a Lambda Web Function, Lambda Function URL, or Amazon API Gateway.
6. Configure the appropriate permissions and environment variables.
7. Deploy the backend and test its endpoints.
8. Copy the deployed HTTPS endpoint into the Flutter application's API configuration.

The precise deployment procedure depends on the AWS service and function configuration used by the project.

### 5. Run the Flutter Application

After configuring the AWS endpoint, run:

```bash
flutter run
```


The application should communicate with the deployed AWS backend when the relevant API integration is implemented and configured correctly.

## Security

- Never commit AWS credentials, access keys, passwords, or private tokens to GitHub.
- Do not embed AWS secret access keys in the Flutter application.
- Store server-side secrets in appropriate AWS-managed configuration or secret storage.
- Validate incoming API requests and handle errors safely.
- Configure access controls and permissions according to the needs of each endpoint.
- Use HTTPS for communication between the mobile application and the cloud backend.
- Avoid collecting or storing unnecessary personal information.
- Protect user feedback and any uploaded content appropriately.

## Project Status

Fikr Sign is being developed as a collaborative hackathon project focused on accessible communication through Ethiopian Sign Language.

The project uses Flutter for the mobile application and is designed to connect to a cloud-hosted Python/FastAPI backend through AWS Lambda.

The capabilities described in this README represent the project's intended scope. Individual features must be verified through implementation, deployment, and integration testing before being considered complete.

The next development priorities include:

- Completing integration between the Flutter application and the AWS-hosted API.
- Testing API requests and responses in the deployed environment.
- Integrating and evaluating sign recognition components.
- Improving error handling and application reliability.
- Validating sign language content with Deaf community members and qualified Ethiopian Sign Language experts.

## Contributing

Team members should coordinate changes across the frontend, backend, and AI components to ensure compatibility.


- Test the affected features.
- Verify API endpoint paths and request and response formats.
- Keep API configuration consistent across the application.
- Document dependencies and setup instructions.
- Avoid committing credentials, secrets, or sensitive user data.
- Update project documentation when functionality changes.

## Team

Fikr Sign is a collaborative hackathon project with contributions across application development, backend API development, AI integration, and UI/UX design.
## Betelhem Nurlachw godie
## Fikirte Alemayehu Achamyeleh
## Mahilet Andualem Beyene
## Soleyana Abera Derara
## Soliyana Shewalante Mengesha

## Vision

Our vision is to create a more inclusive digital environment where deaf and hearing people can communicate more easily through technology.

By combining accessible mobile design, cloud-based services, and Ethiopian Sign Language resources, Fikr Sign aims to support more inclusive communication.

---

**Fikr Sign — Communication for Everyone.** 🤟
