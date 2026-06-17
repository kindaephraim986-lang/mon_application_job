/// ⚠️ DÉPRÉCIÉ: Utilisez ApiService à la place
/// 
/// Ce service a été fusionné dans ApiService pour éviter la duplication de code.
/// Toutes les méthodes d'authentification sont maintenant dans:
/// - ApiService.login()
/// - ApiService.register()
/// - ApiService.logout()
/// - ApiService.getCurrentUser()
/// 
/// Migration:
/// - AuthService.loginUser(email, pwd) → ApiService.login(email: email, password: pwd)

// Importez ApiService à la place
export 'api_service.dart';


