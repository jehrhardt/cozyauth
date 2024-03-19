use cozyauth::app;

fn main() {
    let greeting = app::greeting("cozyauth");
    println!("{}", greeting);
}
