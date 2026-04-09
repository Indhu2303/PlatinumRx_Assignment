def convert_minutes(total_minutes):
    hours           = total_minutes // 60   
    remaining_mins  = total_minutes % 60    

   
    if hours == 1:
        hour_str = "1 hr"
    else:
        hour_str = f"{hours} hrs"

    
    if remaining_mins == 1:
        min_str = "1 minute"
    else:
        min_str = f"{remaining_mins} minutes"

    return f"{hour_str} {min_str}"


if __name__ == "__main__":
    print("\n--- Interactive Mode ---")
    while True:
        user_input = input("Enter minutes (or 'q' to quit): ")
        if user_input.lower() == 'q':
            break
        try:
            mins = int(user_input)
            if mins < 0:
                print("Please enter a positive number.")
            else:
                print(f"Result: {convert_minutes(mins)}")
        except ValueError:
            print("Please enter a valid integer.")
