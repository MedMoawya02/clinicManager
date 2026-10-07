<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.clinicmanager.model.Patient" %>
<%@ include file="/WEB-INF/views/patient/_layout.jspf" %>
<%
    Patient patient = (Patient) request.getAttribute("patient");
    request.setAttribute("activePage", "profile");
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Mon profil – ClinicManager</title>
    <link rel="stylesheet" href="<%= ctx %>/css/patient.css">
</head>
<body>
<%@ include file="/WEB-INF/views/patient/_sidebar.jspf" %>

<main class="main">
    <div class="topbar">
        <div>
            <h1>Mon profil</h1>
            <p>Voici les informations enregistrées dans votre dossier.</p>
        </div>
        <a class="btn btn-primary" href="<%= ctx %>/patient/edit">Modifier</a>
    </div>

    <% if (session.getAttribute("flash") != null) { %>
    <div class="alert alert-success">
        <%= esc(session.getAttribute("flash")) %>
        <% session.removeAttribute("flash"); %>
    </div>
    <% } %>

    <section class="panel">
        <div class="panel-head"><h2>Identité</h2></div>
        <div class="panel-body">
            <div class="info-grid">
                <div class="info-item"><div class="lbl">CIN</div><div class="val"><%= esc(patient.getCin()) %></div></div>
                <div class="info-item"><div class="lbl">Nom</div><div class="val"><%= esc(patient.getNom()) %></div></div>
                <div class="info-item"><div class="lbl">Prénom</div><div class="val"><%= esc(patient.getPrenom()) %></div></div>
                <div class="info-item"><div class="lbl">Date de naissance</div><div class="val"><%= patient.getDateNaissance() != null ? esc(patient.getDateNaissance().toString()) : "—" %></div></div>
                <div class="info-item"><div class="lbl">Genre</div><div class="val"><%= patient.getGenre() != null ? esc(patient.getGenre().getLabel()) : "—" %></div></div>
                <div class="info-item"><div class="lbl">Groupe sanguin</div><div class="val"><%= patient.getGroupeSanguin() != null ? esc(patient.getGroupeSanguin().getLabel()) : "—" %></div></div>
            </div>
        </div>
    </section>

    <section class="panel">
        <div class="panel-head"><h2>Coordonnées</h2></div>
        <div class="panel-body">
            <div class="info-grid">
                <div class="info-item"><div class="lbl">Téléphone</div><div class="val"><%= esc(patient.getTelephone()) %></div></div>
                <div class="info-item"><div class="lbl">Adresse</div><div class="val"><%= esc(patient.getAdresse()) %></div></div>
            </div>
        </div>
    </section>
</main>
</body>
</html>