<!-- Formulaire pour l'exemple 3 -->
<form method="POST" action="products/create">
    <label for="name">Nom du produit:</label>
    <input type="text" id="name" name="name" required />
    
    <label for="price">Prix:</label>
    <input type="number" step="0.01" id="price" name="price" required />
    
    <label for="quantity">Quantité:</label>
    <input type="number" id="quantity" name="quantity" required />
    
    <button type="submit">Créer</button>
</form>

<!-- Formulaire pour l'exemple 1 et 2 -->
<form method="GET" action="products">
    <label for="productId">ID du produit:</label>
    <input type="number" id="productId" name="id" required />
    <button type="submit">Voir le produit</button>
</form>