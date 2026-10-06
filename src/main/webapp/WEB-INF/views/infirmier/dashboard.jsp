<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="../templates/header.jsp" />

<div class="space-y-6">
    <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 border-b border-slate-800 pb-5">
        <div>
            <h2 class="text-2xl font-bold text-white tracking-wide">File d'attente des Patients</h2>
            <p class="text-sm text-slate-400 mt-1">Liste des patients enregistrés aujourd'hui par ordre d'arrivée.</p>
        </div>
        <a href="${pageContext.request.contextPath}/infirmier/recherche" 
           class="inline-flex items-center gap-2 bg-emerald-600 hover:bg-emerald-500 text-white font-medium px-4 py-2.5 rounded-xl shadow-lg shadow-emerald-600/20 border border-emerald-500/30 transition text-sm">
            <span>➕</span> Accueillir un Patient
        </a>
    </div>

    <!-- Alert de succès -->
    <c:if test="${not empty param.msg}">
        <div class="p-4 rounded-xl bg-emerald-500/10 border border-emerald-500/30 text-emerald-300 text-sm flex items-center gap-2">
            <span>✅</span> ${param.msg}
        </div>
    </c:if>

    <!-- Tableau des patients -->
    <div class="bg-slate-800/50 backdrop-blur-md rounded-2xl border border-slate-700/50 overflow-hidden shadow-xl">
        <table class="w-full text-left border-collapse">
            <thead class="bg-slate-800/80 border-b border-slate-700/50 text-xs font-semibold text-slate-400 uppercase tracking-wider">
                <tr>
                    <th class="px-6 py-4">Nom & Prénom</th>
                    <th class="px-6 py-4">N° Sécurité Sociale</th>
                    <th class="px-6 py-4">Heure d'arrivée</th>
                    <th class="px-6 py-4">Signes Vitaux</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-slate-700/50 text-sm">
                <c:forEach items="${patients}" var="p">
                    <tr class="hover:bg-slate-700/30 transition">
                        <td class="px-6 py-4 font-semibold text-white">${p.nom} ${p.prenom}</td>
                        <td class="px-6 py-4 text-slate-300 font-mono">${p.numeroSecuriteSociale}</td>
                        <td class="px-6 py-4 text-slate-400">
                            <c:if test="${not empty p.signesVitaux}">
                                ${p.signesVitaux[p.signesVitaux.size() - 1].datePrise}
                            </c:if>
                        </td>
                        <td class="px-6 py-4">
                            <c:if test="${not empty p.signesVitaux}">
                                <div class="flex flex-wrap gap-2 text-xs font-medium">
                                    <span class="bg-indigo-500/20 text-indigo-300 border border-indigo-500/30 px-2.5 py-1 rounded-lg">
                                        Tension: ${p.signesVitaux[p.signesVitaux.size() - 1].tensionArterielle}
                                    </span>
                                    <span class="bg-amber-500/20 text-amber-300 border border-amber-500/30 px-2.5 py-1 rounded-lg">
                                        Temp: ${p.signesVitaux[p.signesVitaux.size() - 1].temperature}°C
                                    </span>
                                    <span class="bg-rose-500/20 text-rose-300 border border-rose-500/30 px-2.5 py-1 rounded-lg">
                                        Pouls: ${p.signesVitaux[p.signesVitaux.size() - 1].frequenceCardiaque} bpm
                                    </span>
                                </div>
                            </c:if>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty patients}">
                    <tr>
                        <td colspan="4" class="px-6 py-8 text-center text-slate-500">
                            Aucun patient enregistre dans la file d'attente aujourd'hui.
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>

<jsp:include page="../templates/footer.jsp" />