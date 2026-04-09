def remove_duplicates(input_string):
    result = ""  

    for char in input_string:
        if char not in result:   
            result += char       

    return result



if __name__ == "__main__":
    print("\n--- Interactive Mode ---")
    while True:
        user_input = input("Enter a string (or 'q' to quit): ")
        if user_input.lower() == 'q':
            break
        print(f"Result: {remove_duplicates(user_input)}")
