<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="fr">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Control Tower - Back Office</title>
	<link rel="stylesheet" href="${pageContext.request.contextPath}/css/welcome.css">
</head>
<body>
	<div class="container">
		<header>
			<h1>🚗 Control Tower Back Office</h1>
			<p class="subtitle">Système de Gestion de Réservation de Navettes Touristiques</p>
		</header>

		<div class="main-content">
			<h2>Bienvenue sur la Plateforme Control Tower</h2>
			<p class="description">
				Control Tower est une solution complète de gestion back office pour les agences de voyage 
				spécialisées dans les réservations de navettes touristiques. Notre plateforme vous permet 
				de gérer efficacement tous les aspects de votre service de transport : des itinéraires de 
				voiture aux horaires, en passant par la disponibilité en temps réel et la réservation client.
			</p>
			<p class="description">
				Conçu pour les professionnels du tourisme, ce système centralise toutes les opérations 
				de votre tour de contrôle dans une interface intuitive et performante.
			</p>
		</div>

		<div class="features">
			<div class="feature-card">
				<h3>Gestion des Itinéraires</h3>
				<p>
					Créez, modifiez et optimisez vos itinéraires de navettes. Gérez les points de départ, 
					d'arrivée et les arrêts intermédiaires avec précision. Calculez automatiquement les 
					distances et les temps de trajet.
				</p>
			</div>

			<div class="feature-card">
				<h3>Planification des Horaires</h3>
				<p>
					Organisez vos horaires de départ et d'arrivée. Gérez les fréquences de passage, 
					les rotations des véhicules et assurez une couverture optimale pour vos clients 
					tout au long de la journée.
				</p>
			</div>

			<div class="feature-card">
				<h3>Disponibilité en Temps Réel</h3>
				<p>
					Suivez la disponibilité de votre flotte de véhicules en temps réel. Consultez 
					le nombre de places disponibles, gérez les réservations et évitez les surréservations 
					grâce à notre système intelligent.
				</p>
			</div>

			<div class="feature-card">
				<h3>Gestion des Réservations</h3>
				<p>
					Centralisez toutes vos réservations client. Consultez, modifiez ou annulez les 
					réservations facilement. Générez des rapports détaillés sur l'occupation et 
					les revenus.
				</p>
			</div>

			<div class="feature-card">
				<h3>Gestion de la Flotte</h3>
				<p>
					Administrez votre parc de véhicules : capacité, statut, maintenance. Assignez 
					les véhicules aux différents itinéraires et optimisez l'utilisation de votre flotte.
				</p>
			</div>

			<div class="feature-card">
				<h3>Rapports & Statistiques</h3>
				<p>
					Accédez à des tableaux de bord détaillés avec statistiques de fréquentation, 
					taux d'occupation, revenus générés et analyses de performance pour optimiser 
					votre service.
				</p>
			</div>
		</div>

		<div class="info-section">
			<h3>Fonctionnalités Principales</h3>
			<ul class="info-list">
				<li>Interface d'administration intuitive et responsive</li>
				<li>Gestion multi-utilisateurs avec niveaux d'accès</li>
				<li>Synchronisation en temps réel des données</li>
				<li>Système de notifications automatiques</li>
				<li>Export de données aux formats CSV et PDF</li>
				<li>Historique complet des opérations</li>
				<li>Système de recherche avancée</li>
				<li>Gestion des tarifs et promotions</li>
			</ul>
		</div>

		<div class="main-content" style="text-align: center;">
			<h2>Prêt à Commencer ?</h2>
			<p class="description">
				Connectez-vous à votre compte pour accéder au tableau de bord et commencer 
				à gérer votre service de navettes touristiques.
			</p>
			<a href="${pageContext.request.contextPath}/login" class="cta-button">Accéder au Dashboard</a>
		</div>

		<footer>
			<p>&copy; <%= new java.util.Date().getYear() + 1900 %> Control Tower Back Office. Tous droits réservés.</p>
			<p>Solution de gestion professionnelle pour agences de voyage</p>
		</footer>
	</div>
</body>
</html>
