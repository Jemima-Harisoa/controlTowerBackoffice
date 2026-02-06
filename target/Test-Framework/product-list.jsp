<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>

<!DOCTYPE html>
<html>
<head>
    <title>Liste des produits</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 1200px;
            margin: 50px auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        h1 {
            color: #333;
            border-bottom: 3px solid #4CAF50;
            padding-bottom: 10px;
        }
        .header-section {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .stats {
            display: flex;
            gap: 20px;
        }
        .stat-item {
            text-align: center;
            padding: 15px 25px;
            background: #f0f0f0;
            border-radius: 8px;
        }
        .stat-value {
            font-size: 32px;
            font-weight: bold;
            color: #4CAF50;
        }
        .stat-label {
            font-size: 14px;
            color: #666;
            margin-top: 5px;
        }
        .products-container {
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #999;
        }
        .empty-state-icon {
            font-size: 80px;
            margin-bottom: 20px;
        }
        .product-card {
            background: #fafafa;
            border: 1px solid #e0e0e0;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 15px;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .product-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
        .product-header {
            display: flex;
            justify-content: space-between;
            align-items: start;
            margin-bottom: 15px;
        }
        .product-title {
            font-size: 20px;
            font-weight: bold;
            color: #333;
            margin: 0;
        }
        .product-price {
            font-size: 24px;
            font-weight: bold;
            color: #4CAF50;
        }
        .product-details {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-top: 15px;
        }
        .detail-item {
            padding: 10px;
            background: white;
            border-radius: 5px;
        }
        .detail-label {
            font-size: 12px;
            color: #666;
            text-transform: uppercase;
            margin-bottom: 5px;
        }
        .detail-value {
            font-size: 14px;
            color: #333;
            font-weight: 500;
        }
        .tag {
            display: inline-block;
            background: #2196F3;
            color: white;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 11px;
            margin-right: 5px;
            margin-top: 5px;
        }
        .status-badge {
            display: inline-block;
            padding: 5px 12px;
            border-radius: 15px;
            font-size: 12px;
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
        .priority-badge {
            padding: 5px 12px;
            border-radius: 15px;
            font-size: 12px;
            font-weight: bold;
        }
        .priority-high {
            background: #ffcdd2;
            color: #c62828;
        }
        .priority-medium {
            background: #ffe0b2;
            color: #e65100;
        }
        .priority-low {
            background: #c8e6c9;
            color: #2e7d32;
        }
        .description-text {
            margin-top: 15px;
            padding: 15px;
            background: #f5f5f5;
            border-left: 4px solid #4CAF50;
            border-radius: 4px;
            font-size: 14px;
            color: #555;
            line-height: 1.6;
        }
        .btn {
            padding: 12px 30px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            text-decoration: none;
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
        .back-link {
            display: inline-block;
            margin-top: 20px;
            color: #4CAF50;
            text-decoration: none;
            font-size: 16px;
        }
        .back-link:hover {
            text-decoration: underline;
        }
        .product-number {
            display: inline-block;
            width: 30px;
            height: 30px;
            background: #4CAF50;
            color: white;
            border-radius: 50%;
            text-align: center;
            line-height: 30px;
            font-weight: bold;
            margin-right: 10px;
        }
    </style>
</head>
<body>
    <h1>📦 Liste des produits</h1>
    
    <c:set var="products" value="${requestScope.products}" />
    <c:set var="totalProducts" value="${requestScope.totalProducts}" />
    <c:if test="${totalProducts == null}">
        <c:set var="totalProducts" value="${not empty products ? products.size() : 0}" />
    </c:if>
    
    <div class="header-section">
        <div class="stats">
            <div class="stat-item">
                <div class="stat-value">${totalProducts}</div>
                <div class="stat-label">Produits enregistrés</div>
            </div>
        </div>
        <div>
            <a href="${pageContext.request.contextPath}/products" class="btn btn-primary">
                ➕ Créer un nouveau produit
            </a>
        </div>
    </div>
    
    <div class="products-container">
        <c:if test="${empty products}">
            <div class="empty-state">
                <div class="empty-state-icon">📭</div>
                <h2>Aucun produit pour le moment</h2>
                <p>Commencez par créer votre premier produit en utilisant un des formulaires disponibles.</p>
                <a href="${pageContext.request.contextPath}/products" class="btn btn-primary" style="margin-top: 20px;">
                    🏠 Aller aux formulaires
                </a>
            </div>
        </c:if>
        <c:if test="${not empty products}">
            <c:forEach var="product" items="${products}" varStatus="status">
                <c:set var="index" value="${status.index + 1}" />
            <div class="product-card">
                <div class="product-header">
                    <div>
                        <span class="product-number">${index}</span>
                        <h3 class="product-title" style="display: inline;">${product.name}</h3>
                    </div>
                    <div class="product-price">${product.price} €</div>
                </div>
                
                <div class="product-details">
                    <div class="detail-item">
                        <div class="detail-label">Quantité</div>
                        <div class="detail-value">📊 ${product.quantity} unité(s)</div>
                    </div>
                    
                    <c:if test="${not empty product.category}">
                    <div class="detail-item">
                        <div class="detail-label">Catégorie</div>
                        <div class="detail-value">📋 ${product.category}</div>
                    </div>
                    </c:if>
                    
                    <c:if test="${not empty product.priority}">
                    <div class="detail-item">
                        <div class="detail-label">Priorité</div>
                        <div class="detail-value">
                            <c:set var="priorityClass" value="priority-low" />
                            <c:set var="priorityIcon" value="🟢" />
                            <c:if test="${product.priority == 'Haute'}">
                                <c:set var="priorityClass" value="priority-high" />
                                <c:set var="priorityIcon" value="🔴" />
                            </c:if>
                            <c:if test="${product.priority == 'Moyenne'}">
                                <c:set var="priorityClass" value="priority-medium" />
                                <c:set var="priorityIcon" value="🟠" />
                            </c:if>
                            <span class="priority-badge ${priorityClass}">
                                ${priorityIcon} ${product.priority}
                            </span>
                        </div>
                    </div>
                    </c:if>
                    
                    <div class="detail-item">
                        <div class="detail-label">Disponibilité</div>
                        <div class="detail-value">
                            <span class="status-badge ${product.inStock ? 'status-available' : 'status-unavailable'}">
                                ${product.inStock ? '✓ En stock' : '✗ Rupture'}
                            </span>
                        </div>
                    </div>
                </div>
                
                <c:if test="${not empty product.tags}">
                <div style="margin-top: 15px;">
                    <div class="detail-label" style="margin-bottom: 8px;">TAGS</div>
                    <c:forEach var="tag" items="${product.tags}">
                        <span class="tag">${tag}</span>
                    </c:forEach>
                </div>
                </c:if>
                
                <c:if test="${not empty product.description}">
                <div class="description-text">
                    <strong>Description :</strong><br>
                    ${fn:replace(product.description, '\\n', '<br>')}
                </div>
                </c:if>
            </div>
            </c:forEach>
        </c:if>
    </div>
    
    <a href="${pageContext.request.contextPath}/products" class="back-link">
        ← Retour à l'accueil des formulaires
    </a>
</body>
</html>