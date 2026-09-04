// A simple struct to represent a user
struct User {
    username: String,
    active: bool,
}

// An enum representing possible application states
enum Status {
    Success,
    Error(String),
}

fn main() {
    // 1. Variables are immutable by default
    let name = String::from("Alice");
    
    // 2. Use 'mut' to make a variable mutable
    let mut login_count = 0;
    login_count += 1;

    // 3. Instantiating a struct
    let user = User {
        username: name,
        active: true,
    };

    // 4. Using an 'if' statement as an expression
    let message = if user.active {
        "User is online"
    } else {
        "User is offline"
    };
    println!("{}", message);

    // 5. Pattern matching with an enum
    let current_status = Status::Error(String::from("Connection failed"));

    match current_status {
        Status::Success => println!("Operation succeeded!"),
        Status::Error(msg) => println!("Operation failed with error: {}", msg),
    }

    // 6. Handling safe errors with Option
    let item = find_item(42);
    match item {
        Some(name) => println!("Found item: {}", name),
        None => println!("Item not found."),
    }
}

// A function that returns an Option (can be something or nothing)
fn find_item(id: u32) -> Option<String> {
    if id == 42 {
        Some(String::from("Rusty Widget"))
    } else {
        None
    }
}

