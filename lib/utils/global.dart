import 'package:firebase/firebase.dart';
import 'package:firebase/firestore.dart';

bool isLoggedIn = false;
var langue = English;
var tab;
final auth_fire = auth();
Firestore bdd_fire = firestore();

var Francais = {
  //appbar
  'home': 'Accueil',
  'search_user': 'Rechercher',
  'infos': 'Mes infos',
  'disconnect': 'Deconnexion',
  //actions
  'read_movie': "Regarder le film",

  'sort_label': "Trier par",
  'filter_max_empty': "Merci de remplir aussi le maximum",
  'filter_min_empty': "Merci de remplir aussi le minimum",
  'filter_max_inf': "Le max ne peut pas etre inferieure au min",
  'filter_min_sup': "Le min ne peut pas etre superieur au max",

  'filter_minrating_label': "Valeur minimum de la note",
  'filter_minrating_hint': "Valeur minimum",
  'filter_maxrating_label': "Valeur maximum de la note",
  'filter_maxrating_hint': "Valeur maximum",

  'filter_minyear_label': "Annee de production minimum",
  'filter_minyear_hint': "Annee minimum",
  'filter_maxyear_label': "Annee de production maximum",
  'filter_maxyear_hint': "Annee maximum",

  'search_label': "Rechercher",
  'search_hint_text': "Rechercher un utilisateur",
  'search_hint_movie': "Rechercher un film",

  'modif_label': "Modifier mes informations",
  'modif_progress': 'Modification en cours',
  'modif_success': 'Modification reussie',
  'modif_error': 'Erreur de modification',

  'signup_label': "S'inscrire",
  'signup_google_label': "S'inscrire avec Google",
  'signup_42_label': "S'inscrire avec 42",
  'signup_progress': 'Inscription en cours',
  'signup_success': 'Inscription reussie',

  'signin_label': "Se connecter",
  'signin_google_label': "Se connecter avec Google",
  'signin_42_label': "Se connecter avec 42",
  'signin_progress': 'Connexion en cours',
  'signin_success': 'Connexion reussie',
  'signin_error': 'Erreur de connexion',
  //global errors
  'invalid_mail': "Adresse mail deja utilisée",
  'user_not_found': "Utilisateur introuvable",
  'null_field': 'Merci de ne pas laisser ce champ vide',
  //forms
  'mail_enter': 'Entrez votre adresse mail',
  'mail_label': 'Adresse mail',
  'username_enter': 'Entrez votre nom d\'utilisateur',
  'username_search_enter': 'Entrez un nom d\'utilisateur',
  'username_label': "Nom d'utilisateur",
  'fname_enter': 'Entrez votre Nom',
  'fname_label': 'Nom',
  'lname_enter': 'Entrez votre Prenom',
  'lname_label': 'Prenom',
  'pp_enter': 'Entrez l\'url de votre photo de profil',
  'pp_label': "Photo de profil",
  'langue_label': "Langue par default",
  'pass_enter': 'Entrez votre mot de passe',
  'pass_label': "Mot de passe",
};

var English = {
  //appbar
  'home': 'Home',
  'search_user': 'Search User',
  'infos': 'My info',
  'disconnect': 'Sign Out',
  //actions
  'read_movie': "Show the movie",

  'sort_label': "Sort by",
  'filter_max_empty': "Please enter an maximum value",
  'filter_min_empty': "Please enter an minimum value",
  'filter_max_inf': "Max value cannot be inferior of min",
  'filter_min_sup': "Min value cannot be superior of max",

  'filter_minrating_label': "Minimum rating value",
  'filter_minrating_hint': "Min value",
  'filter_maxrating_label': "Maximum rating value",
  'filter_maxrating_hint': "Max value",

  'filter_minyear_label': "Production year minimum",
  'filter_minyear_hint': "Minimum year",
  'filter_maxyear_label': "Production year maximum",
  'filter_maxyear_hint': "Maximum year",

  'search_label': "Search",
  'search_hint_text': "Search any user",
  'search_hint_movie': "Search movie",

  'modif_label': "Edit my information",
  'modif_progress': 'Modification in progress',
  'modif_success': 'Successful modification',
  'modif_error': 'Modification error',

  'signup_label': "Register",
  'signup_google_label': "Register with Google",
  'signup_42_label': "Register with 42",
  'signup_progress': 'Registration in progress',
  'signup_success': 'Successful registration',

  'signin_label': "Sign in",
  'signin_google_label': "Sign in with Google",
  'signin_42_label': "Sign in with 42",
  'signin_progress': 'Sign in in progress',
  'signin_success': 'Successful sign in',
  'signin_error': 'Sign in error',
  //global errors
  'invalid_mail': "That email adress is already used",
  'user_not_found': "User not found",
  'null_field': 'Please enter something',
  //forms
  'mail_enter': 'Enter your email address',
  'mail_label': 'Email address',
  'username_enter': 'Enter your username',
  'username_search_enter': 'Enter an username',
  'username_label': 'Username',
  'fname_enter': 'Enter your last name',
  'fname_label': 'Last Name',
  'lname_enter': 'Enter your first name',
  'lname_label': 'First Name',
  'pp_enter': 'Enter the URL of your profile picture',
  'pp_label': "Profile Picture",
  'langue_label': "Default Language",
  'pass_enter': 'Enter your password',
  'pass_label': "Password",
};

class Error {
  final String videError = 'You can\'t leave this field blank';
  final String mailError = 'Need to enter a valid mail';
  final String urlError = "Need to enter a valid URL";

  max(value) {
    return ("The maximum length is " + value.toString() + " characters");
  }

  min(value) {
    return ("The minimum length is " + value.toString() + " characters");
  }
}
