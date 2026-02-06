<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Succès - Produit créé</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 700px;
            margin: 50px auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .success-container {
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .success-header {
            background: #4CAF50;
            color: white;
            padding: 20px;
            border-radius: 8px 8px 0 0;
            margin: -30px -30px 20px -30px;
            text-align: center;
        }
        .success-header h1 {
            margin: 0;
            font-size: 28px;
        }
        .success-icon {
            font-size: 60px;
            margin-bottom: 10px;
        }
        .product-details {
            background: #f9f9f9;
            padding: 20px;
            border-radius: 8px;
            border-left: 4px solid #4CAF50;
            margin: 20px 0;
        }
        .detail-row {
            display: flex;
            padding: 10px 0;
            border-bottom: 1px solid #eee;
        }
        .detail-row:last-child {
            border-bottom: none;
        }
        .detail-label {
            font-weight: bold;
            color: #555;
            width: 150px;
            flex-shrink: 0;
        }
        .detail-value {
            color: #333;
            flex-grow: 1;
        }
        .tag {
            display: inline-block;
            background: #2196F3;
            color: white;
            padding: 5px 12px;
            border-radius: 15px;
            font-size: 12px;
            margin-right: 5px;
            margin-bottom: 5px;
        }
        .actions {
            margin-top: 30px;
            display: flex;
            gap: 10px;
        }
        .btn {
            flex: 1;
            padding: 12px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            text-decoration: none;
            text-align: center;
            transition: background 0.3s;
            display: inline-block;
        }
        .btn-primary {
            background: #4CAF50;
            color: white;
        }
        .btn-primary:hover {
            background: #45a049;
        }
        .btn-secondary {
            background: #2196F3;
            color: white;
        }
        .btn-secondary:hover {
            background: #0b7dda;
        }
        .btn-info {
            background: #ff9800;
            color: white;
        }
        .btn-info:hover {
            background: #e68900;
        }
        .status-badge {
            display: inline-block;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: bold;
        }
        .status-available {
            background: #c8e6c9;
            color: #2e7d32;
        }
        .status-unavailable {
            background: #ffcdd2;
            color: #c62828;
        }
    </style>
</head>
<body>
    <div class="success-container">
        <div class="success-header">
            <div class="success-icon">✅</div>
            <h1>Produit créé avec succès !</h1>
            <p style="margin: 10px 0 0 0; font-size: 16px;">
                ${not empty requestScope.message ? requestScope.message : 'Le produit a été ajouté à la base de données'}
            </p>
        </div>
        
        <c:set var="product" value="${requestScope.product}" />
        <c:set var="formType" value="${requestScope.formType}" />
        
        <c:if test="${not empty product}">
        
        <div class="product-details">
            <h2 style="margin-top: 0; color: #4CAF50;">📦 Détails du produit</h2>
            
            <div class="detail-row">
                <div class="detail-label">Nom :</div>
                <div class="detail-value"><strong>${product.name}</strong></div>
            </div>
            
            <div class="detail-row">
                <div class="detail-label">Prix :</div>
                <div class="detail-value"><strong>${product.price} €</strong></div>
            </div>
            
            <div class="detail-row">
                <div class="detail-label">Quantité :</div>
                <div class="detail-value">${product.quantity} unité(s)</div>
            </div>
            
            <c:if test="${not empty product.category}">
            <div class="detail-row">
                <div class="detail-label">Catégorie :</div>
                <div class="detail-value">📋 ${product.category}</div>
            </div>
            </c:if>
            
            <c:if test="${not empty product.priority}">
            <div class="detail-row">
                <div class="detail-label">Priorité :</div>
                <div class="detail-value">
                    <c:set var="priorityIcon" value="🟢" />
                    <c:if test="${product.priority == 'Haute'}">
                        <c:set var="priorityIcon" value="🔴" />
                    </c:if>
                    <c:if test="${product.priority == 'Moyenne'}">
                        <c:set var="priorityIcon" value="🟠" />
                    </c:if>
                    ${priorityIcon} ${product.priority}
                </div>
            </div>
            </c:if>
            
            <c:if test="${not empty product.description}">
            <div class="detail-row">
                <div class="detail-label">Description :</div>
                <div class="detail-value">${product.description}</div>
            </div>
            </c:if>
            
            <c:if test="${not empty product.tags}">
            <div class="detail-row">
                <div class="detail-label">Tags :</div>
                <div class="detail-value">
                    <c:forEach var="tag" items="${product.tags}">
                        <span class="tag">${tag}</span>
                    </c:forEach>
                </div>
            </div>
            </c:if>
            
            <c:if test="${formType == 'complete'}">
            <div class="detail-row">
                <div class="detail-label">Disponibilité :</div>
                <div class="detail-value">
                    <span class="status-badge ${product.inStock ? 'status-available' : 'status-unavailable'}">
                        ${product.inStock ? '✓ En stock' : '✗ Rupture de stock'}
                    </span>
                </div>
            </div>
            </c:if>
        </div>
        
        </c:if>
        <c:if test="${empty product}">
            <p style="color: red;">Erreur : Aucun produit n'a été retourné.</p>
        </c:if>
        
        <div class="actions">
            <a href="${pageContext.request.contextPath}/products" class="btn btn-primary">
                🏠 Retour à l'accueil
            </a>
            
            <c:if test="${not empty formType}">
                <a href="${pageContext.request.contextPath}/products/form-${formType}" class="btn btn-secondary">
                    ➕ Créer un autre
                </a>
            </c:if>
            
            <a href="${pageContext.request.contextPath}/products/list" class="btn btn-info">
                📋 Voir tous les produits
            </a>
        </div>
    </div>
</body>
</html>