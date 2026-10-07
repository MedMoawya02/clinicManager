<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.clinicmanager.model.Appointment" %>
<%@ page import="com.clinicmanager.model.AppointmentStatus" %>
<%@ include file="/WEB-INF/views/patient/_layout.jspf" %>
<%
    List<Appointment> appointments =
            (List<Appointment>) request.getAttribute("appointments");
    request.setAttribute("activePage", "appointments");
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Mes rendez-vous – ClinicManager</title>
    <link rel="stylesheet" href="<%= ctx %>/css/patient.css">
</head>
<body>
<%@ include file="/WEB-INF/views/patient/_sidebar.jspf" %>

<main class="main">
    <div class="topbar">
        <div>
            <h1>Mes rendez-vous</h1>
            <p>Consultez et gérez vos rendez-vous à venir et passés.</p>
        </div>
        <a class="btn btn-primary" href="<%= ctx %>/patient/appointments/new">
            ➕ Prendre un rendez-vous
        </a>
    </div>

    <% if (appointments == null || appointments.isEmpty()) { %>

    <section class="panel">
        <div class="panel-body">
            <p>Aucun rendez-vous pour le moment.</p>
        </div>
    </section>

    <% } else { %>

    <section class="panel">
        <div class="panel-body">
            <table class="table">
                <thead>
                <tr>
                    <th>Date</th>
                    <th>Créneau</th>
                    <th>Médecin</th>
                    <th>Type</th>
                    <th>Motif</th>
                    <th>Statut</th>
                    <th></th>
                </tr>
                </thead>
                <tbody>
                <% for (Appointment a : appointments) { %>
                <tr>
                    <td><%= a.getDate() %></td>

                    <td><%= esc(a.getSlot()) %></td>

                    <td>
                        <% if (a.getDoctor() != null) { %>
                        Dr. <%= esc(a.getDoctor().getNom()) %>
                        <% } else { %>
                        —
                        <% } %>
                    </td>

                    <td>
                        <%= a.getType() != null ? a.getType().name() : "—" %>
                    </td>

                    <td><%= esc(a.getMotif()) %></td>

                    <td>
                                <span class="badge badge-<%= a.getStatus().name().toLowerCase() %>">
                                    <%= a.getStatus().name() %>
                                </span>
                    </td>

                    <td>
                        <% if (a.getStatus() == AppointmentStatus.PLANNED
                                || a.getStatus() == AppointmentStatus.DONE) { %>
                        <form method="post"
                              action="<%= ctx %>/patient/appointments/cancel"
                              style="display:inline">
                            <input type="hidden" name="id" value="<%= a.getId() %>">
                            <button class="btn btn-ghost"
                                    onclick="return confirm('Annuler ce rendez-vous ?');">
                                Annuler
                            </button>
                        </form>
                        <% } %>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </section>

    <% } %>
</main>
</body>
</html>