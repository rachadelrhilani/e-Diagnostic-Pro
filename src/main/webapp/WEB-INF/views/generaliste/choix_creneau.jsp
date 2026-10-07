<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="../templates/header.jsp" />

<div class="max-w-3xl mx-auto p-8 rounded-2xl bg-slate-800/40 border border-slate-700/50 backdrop-blur-md shadow-xl space-y-6">
    <h2 class="text-xl font-bold text-white">Créneaux Disponibles & Poser une Question</h2>

    <form action="${pageContext.request.contextPath}/generaliste/envoyer-demande-expertise" method="post" class="space-y-6">
        <input type="hidden" name="consultationId" value="${consultationId}" />
        <input type="hidden" name="specialisteId" value="${specialisteId}" />

        <div>
            <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">Choisir un Créneau Horaire</label>
            <div class="grid grid-cols-2 gap-3">
                <c:forEach var="c" items="${creneaux}">
                    <label class="flex items-center gap-3 p-3 rounded-xl bg-slate-900 border border-slate-700 cursor-pointer hover:border-indigo-500">
                        <input type="radio" name="creneauId" value="${c.id}" required class="text-indigo-600" />
                        <span class="text-xs text-white">${c.heureDebut} - ${c.heureFin}</span>
                    </label>
                </c:forEach>
            </div>
        </div>

        <div>
            <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">Priorité</label>
            <select name="priorite" class="w-full px-4 py-2.5 rounded-xl bg-slate-900 border border-slate-700 text-white text-sm focus:outline-none">
                <option value="BASSE">Basse</option>
                <option value="MOYENNE" selected>Moyenne</option>
                <option value="HAUTE">Haute</option>
                <option value="URGENTE">Urgente</option>
            </select>
        </div>

        <div>
            <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">Question / Observations & Analyses fournies</label>
            <textarea name="question" rows="4" required placeholder="Décrivez votre question clinique et les analyses..." class="w-full px-4 py-2.5 rounded-xl bg-slate-900 border border-slate-700 text-white text-sm focus:outline-none"></textarea>
        </div>

        <button type="submit" class="w-full py-3 rounded-xl bg-indigo-600 hover:bg-indigo-500 text-white font-semibold text-sm shadow-lg shadow-indigo-600/30 transition">
            Envoyer la Demande d'Expertise
        </button>
    </form>
</div>

<jsp:include page="../templates/footer.jsp" />