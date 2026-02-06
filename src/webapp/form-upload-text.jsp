<%@ include file="page-header.jsp" %>

<div class="card">
    <h3>📤 Upload avec texte</h3>

    <form action="<%= request.getContextPath() %>/products/upload-with-text"
          method="post"
          enctype="multipart/form-data">

        <div class="form-group">
            <label>Nom du produit</label>
            <input type="text" name="name" class="form-control" required>
        </div>

        <div class="form-group">
            <label>Description</label>
            <textarea name="description" class="form-control"></textarea>
        </div>

        <div class="form-group">
            <label>Image</label>
            <input type="file" name="image" class="form-control" required>
        </div>

        <button type="submit" class="btn">Envoyer</button>
    </form>
</div>

<%@ include file="page-footer.jsp" %>
