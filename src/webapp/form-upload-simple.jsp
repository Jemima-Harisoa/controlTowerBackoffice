<%@ include file="page-header.jsp" %>

<div class="card">
    <h3>📤 Upload simple</h3>

    <form action="<%= request.getContextPath() %>/products/upload-simple"
          method="post"
          enctype="multipart/form-data">

        <div class="form-group">
            <label>Fichier</label>
            <input type="file" name="file" class="form-control" required>
        </div>

        <button type="submit" class="btn">Envoyer</button>
    </form>
</div>
<div class="card">
    <h3>📤 Upload multiple </h3>

    <form   action="<%= request.getContextPath() %>/products/upload-multiple"
            method="post"
            enctype="multipart/form-data">

        <input type="file" name="files" multiple class="form-control">
        <button type="submit" class="btn">Envoyer</button>
    </form>

</div>

<%@ include file="page-footer.jsp" %>
