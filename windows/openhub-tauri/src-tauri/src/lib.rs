#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .setup(|app| {
            if let Ok(icon) = tauri::image::Image::from_bytes(include_bytes!("../icons/icon.png")) {
                let _ = app.set_icon(icon);
            }
            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("failed to run OpenHub");
}
