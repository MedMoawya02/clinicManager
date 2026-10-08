<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.clinicmanager.model.Doctor" %>
<%@ page import="com.clinicmanager.model.AppointmentType" %>
<%@ page import="java.time.LocalDate" %>
<%@ include file="/WEB-INF/views/patient/_layout.jspf" %>
<%
    List<Doctor> doctors = (List<Doctor>) request.getAttribute("doctors");
    AppointmentType[] types = (AppointmentType[]) request.getAttribute("types");

//    String activePage = "appointments";
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Prendre un rendez-vous – ClinicManager</title>
    <link rel="stylesheet" href="<%= ctx %>/css/patient.css">
</head>
<body>
<%@ include file="/WEB-INF/views/patient/_sidebar.jspf" %>

<main class="main">
    <div class="topbar">
        <div>
            <h1>Prendre un rendez-vous</h1>
            <p>Choisissez un médecin, une date, un créneau et un motif.</p>
        </div>
        <a class="btn btn-ghost" href="<%= ctx %>/patient/appointments">Annuler</a>
    </div>

    <% if (request.getAttribute("error") != null) { %>
    <div class="alert alert-error"><%= esc(request.getAttribute("error")) %></div>
    <% } %>

    <section class="panel">
        <form method="post" action="<%= ctx %>/patient/book-appointment">
            <div class="panel-body">
                <div class="form-grid">

                    <div class="full">
                        <label class="lbl">Médecin <span class="req">*</span></label>
                        <select name="doctorId" required>
                            <option value="">— choisir un médecin —</option>
                            <% for (Doctor d : doctors) { %>
                            <option value="<%= d.getId() %>">
                                Dr. <%= esc(d.getNom()) %>
                            </option>
                            <% } %>
                        </select>
                    </div>

                    <div>
                        <label class="lbl">Date <span class="req">*</span></label>
                        <input type="date" name="date" required
                               min="<%= LocalDate.now() %>">
                    </div>

                    <div>
                        <label class="lbl">Créneau <span class="req">*</span></label>
                        <select name="slot" required>
                            <option value="">— choisir un créneau —</option>
                            <option value="09:00">09:00</option>
                            <option value="09:30">09:30</option>
                            <option value="10:00">10:00</option>
                            <option value="10:30">10:30</option>
                            <option value="11:00">11:00</option>
                            <option value="11:30">11:30</option>
                            <option value="14:00">14:00</option>
                            <option value="14:30">14:30</option>
                            <option value="15:00">15:00</option>
                            <option value="15:30">15:30</option>
                            <option value="16:00">16:00</option>
                            <option value="16:30">16:30</option>
                        </select>
                    </div>

                    <div>
                        <label class="lbl">Type</label>
                        <select name="type">
                            <option value="">—</option>
                            <% for (AppointmentType t : types) { %>
                            <option value="<%= t.name() %>"><%= t.name() %></option>
                            <% } %>
                        </select>
                    </div>

                    <div class="full">
                        <label class="lbl">Motif</label>
                        <textarea name="motif" rows="3" maxlength="255"></textarea>
                    </div>

                </div>

                <div class="form-actions">
                    <a class="btn btn-ghost" href="<%= ctx %>/patient/appointments">Annuler</a>
                    <button type="submit" class="btn btn-primary">Confirmer</button>
                </div>
            </div>
        </form>
    </section>
</main>
</body>
</html>