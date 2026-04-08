use tauri::Manager;
use std::process::Command;
use std::sync::Mutex;

pub struct AppState {
    pub api_url: Mutex<String>,
}

#[tauri::command]
async fn get_api_config(state: tauri::State<'_, AppState>) -> Result<String, String> {
    Ok(state.api_url.lock().unwrap().clone())
}

#[tauri::command]
fn open_url(url: String) -> Result<(), String> {
    #[cfg(target_os = "linux")]
    {
        Command::new("xdg-open").arg(url).spawn().map_err(|e| e.to_string())?;
    }
    #[cfg(target_os = "windows")]
    {
        Command::new("cmd").args(["/C", "start", "", &url]).spawn().map_err(|e| e.to_string())?;
    }
    #[cfg(target_os = "macos")]
    {
        Command::new("open").arg(url).spawn().map_err(|e| e.to_string())?;
    }
    Ok(())
}

#[tauri::command]
async fn import_database(app_handle: tauri::AppHandle, source_path: String) -> Result<String, String> {
    // Portability: Find the database path next to the executable
    let app_dir = app_handle.path().app_local_data_dir().map_err(|e| e.to_string())?;
    // However, the user wants the DB in app2BackEnd/database/database.sqlite
    // We can resolve this relative to the current working directory or the app resource dir
    let resource_dir = app_handle.path().resource_dir().map_err(|e| e.to_string())?;
    
    // Check local folder first (portable), then resources (installed)
    let mut db_path = std::env::current_dir().unwrap_or_default().join("app2BackEnd/database/database.sqlite");
    if !db_path.exists() {
        db_path = resource_dir.join("app2BackEnd/database/database.sqlite");
    }

    let source = std::path::PathBuf::from(source_path);
    if !source.exists() {
        return Err("Le fichier source n'existe pas.".to_string());
    }
    
    // Copy and overwrite the existing database
    std::fs::copy(&source, &db_path).map_err(|e| format!("Erreur lors de la copie : {}", e))?;
    
    Ok("Base de données importée avec succès. Veuillez redémarrer l'application pour appliquer les changements.".to_string())
}

#[tauri::command]
async fn export_database(app_handle: tauri::AppHandle, destination_path: String) -> Result<String, String> {
    let resource_dir = app_handle.path().resource_dir().map_err(|e| e.to_string())?;
    
    let mut db_path = std::env::current_dir().unwrap_or_default().join("app2BackEnd/database/database.sqlite");
    if !db_path.exists() {
        db_path = resource_dir.join("app2BackEnd/database/database.sqlite");
    }
    
    if !db_path.exists() {
        return Err("La base de données actuelle n'existe pas.".to_string());
    }
    
    let destination = std::path::PathBuf::from(destination_path);
    std::fs::copy(&db_path, &destination).map_err(|e| format!("Erreur lors de l'exportation : {}", e))?;
    
    Ok("Base de données exportée avec succès.".to_string())
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .setup(|app| {
            // Use environment variable or default to localhost:8000
            let api_url = std::env::var("APP_API_URL")
                .unwrap_or_else(|_| "http://127.0.0.1:8000/api".to_string());
            
            app.manage(AppState {
                api_url: Mutex::new(api_url),
            });
            Ok(())
        })
        .invoke_handler(tauri::generate_handler![open_url, get_api_config, import_database, export_database])
        .plugin(tauri_plugin_dialog::init())
        .build(tauri::generate_context!())
        .expect("error while building tauri application")
        .run(|_app_handle, _event| {
            // No child processes to clean up anymore
        });
}