# OurlandQuiz
Quiz Platform to submit Q and A about Hong Kong Modern History and Fake news Bluster

## Getting Started

This project is a using flutter for web. Please refer to https://flutter.dev/docs/get-started/web to setup the envirnoment


## Project Setup
1. Create a Firebase project and setup your application
  * Add a project
      * Go to Firebase: https://console.firebase.google.com
      * Click on Add Project
      * Input project name as OurLandQuiz > Leave anything default > Accept controller-controller terms > Create Project
  * Enable Authentication
  		* To let users sign-in on the web app we'll use *Google* auth currently, which needs to be enabled.	
  		* In the Firebase Console open the Authentication section > SIGN IN METHOD tab you need to enable the Google Sign-in Provider and click SAVE. This will allow users to sign-in the Web app with their Google accounts
	* Restore Database
		* Install firestore-back-restore: https://www.npmjs.com/package/firestore-backup-restore
		* Retrieving Google Cloud Account Credentials with above link and put into path/to/restore/credentials/file.json
		* Extract the sample/sampledb.zip into ./backups/myDatabase
		* Run `firestore-backup-restore --backupPath ./backups/myDatabase --restoreAccountCredentials path/to/restore/credentials/file.json`


2. Install the Firebase Command Line Interface (**For Windows, please use Powershell with administrator privileges**)
    * Install Node.js: https://nodejs.org/en/
	  * Install windows-build-tools on Windows environment:
    `npm install --global --production windows-build-tools`
    * Checkout the source code
    * Install project dependencies
      ```bash
      cd <Project Foloder>
      flutter pub get
      cd functions
      npm install
      ```
    * Setup firebase configuration
  		```bash
  		cd ..
  		firebase login
  		firebase use --add
  		npm run generate_firebase_config
	    ```
    * Debug the project
      ```bash
      flutter run -d chrome
    * Build the project
      ```bash
      flutter build web
      serve -s build
      ```
    * Deploy the project
      ```bash
      flutter build web
      firebase deploy
      ```
3. Test your project
	*   Go to https://`<project-id>`.firebaseapp.com
