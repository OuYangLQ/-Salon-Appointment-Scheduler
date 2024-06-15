#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon  --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
	if [[ $1 ]]
	then
		echo -e $1
	else
		echo -e "Welcome to My Salon, how can I help you?\n"
	fi

	APPOINTMENT_MENU
	
}

APPOINTMENT_MENU() {
	# get services
	SERVICES=$($PSQL "SELECT service_id,name FROM services")
	echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
	do
		echo "$SERVICE_ID) $SERVICE_NAME"
	done

	read SERVICE_ID_SELECTED
	SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
	SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
	if [[ -z $SERVICE_ID ]]
	then
		MAIN_MENU "\nI could not find that service. What would you like today?"
	else
		echo -e "What's your phone number?"
		read CUSTOMER_PHONE
		CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
		if [[ -z $CUSTOMER_ID ]]
		then
			echo -e "I don't have a record for that phone number, what's your name?"
			read CUSTOMER_NAME
			CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (phone,name) VALUES ('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
			CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
		else
			CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
		fi

		echo -e "What time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
		read SERVICE_TIME
		APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id ,service_id ,time) VALUES($CUSTOMER_ID ,$SERVICE_ID ,'$SERVICE_TIME')")
		echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
	fi
}


MAIN_MENU
