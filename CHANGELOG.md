## V1.0.1 (2025-12-22) :
- bug fix : add time slot button in time slots set editor menu does not work
- Bug fix in schedules page : create new schedule item fails

## V1.0.0 (2025-11-23) :
- Updated for flutter 3.38.3 compatibility

## V0.9.0 (2025-01-29) :
- Compatibility with server v1.2.0 :
	- schedules inheritance handling
	- new is_alive message format (containing current date and server version)
- Settings page : "server version" is visible
- Settings : mqtt server parameters are now stored in secured storage
- Schedule widget :
	- parent schedule is visible
	- Edit button allows parent schedule change
	- Week days can now be unselected
	- Move up / Move Down button moved to schedule item menu

## V0.8.1 (2025-01-13) :
- Moved edit devices list button to settings page
- Fixed deprecated API use
- Fixed build warnings
- Added info message when mqtt parameters are not set and when devices list is empty

## V0.8.0 (2025-01-11) :
- Upgraded to flutter 3.27.1
- bug fix : thermostat +/- buttons malfunctionning in some circumstances
- bug fix : Server connection lost notification was sent when app was in inactive state (even if connection was ok)
- Compatibility with server v1.1.0 :
	- "Manual setpoint reset mode" parameter added in settings page
- Added logging in source code
- Android/web/linux folders have been re-generated to conform to new flutter project template

## V0.7.1 (2024-01-18) :
- bug fix : weeks A / B calculation was wrong
- Removed the snackbar poping on server connected/disconnected notifications
- When server is not connected : 
	- Added a blur effect and a text
	- All shown element are read only
	- Settings page is still accessible in read/write

## V0.7.0 (2023-12-18) :
- added multi-languages support
- added English language

## V0.6.0 (2023-12-11) :
- upgraded to flutter 3.16.3
- A red mark is now shown on active schedule elements
- Compatibility with server v1.0.0 :
	- added button to create a device from server entity
	- added button to remove an existing device
	- added combo box to change a device entity

## V0.5.0 (2023-11-23) :
- compatibility with server v0.9.5 : added odd/even weeks in schedules item
- upgraded to flutter 3.16.0
- upgraded dependencies
- fixed many user experience related issues (desktop and mobile targets)

## V0.4.0 (2023-11-19) :
- Update for server v0.9.4 interface compatibility
	- Reading of IsAlive message to change connexion icon color dynamically
	- Reading of min/max temperatures in devices data 
- upgraded dependencies to latest versions
- added settings page with theme selection and mqtt settings
- bug fix : now working without secrets.yaml
- added minSetpoint and maxSetpoint default value to config.yaml

## V0.3.0 (2023-02-18) :
- Update for server v0.9.3 interface compatibility
- Added devices editor to reorder devices and change their name

## V0.2.0 (2023-02-08) :
- Update for server v0.9.1 compatibility