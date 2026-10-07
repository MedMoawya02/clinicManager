<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="/WEB-INF/views/patient/_layout.jspf" %>
<% request.setAttribute("activePage", "history"); %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Historique médical – ClinicManager</title>
    <link rel="stylesheet" href="<%= ctx %>/css/patient.css">
</head>
<body>
<%@ include file="/WEB-INF/views/patient/_sidebar.jspf" %>

<main class="main">
    <div class="topbar">
        <div>
            <h1>Historique médical</h1>
            <p>Retrouvez ici vos notes et antécédents médicaux.</p>
        </div>
    </div>

    <section class="panel">
        <div class="panel-body" style="text-align:center;padding:40px 20px;color:var(--muted)">
            <p style="font-size:16px">📋</p>
            <p>Aucun historique disponible.</p>
            <p style="font-size:13px;margin-top:8px">Cette fonctionnalité sera disponible prochainement.</p>
        </div>
    </section>
</main>
</body>
</html>