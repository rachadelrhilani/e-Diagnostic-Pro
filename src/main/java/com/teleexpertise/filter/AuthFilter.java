package com.teleexpertise.filter;

import com.teleexpertise.model.Role;
import com.teleexpertise.model.Utilisateur;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebFilter("/*")
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        String path = req.getRequestURI().substring(req.getContextPath().length());

        // 1. Autoriser toutes les routes d'authentification (/auth/*) et les ressources statiques
        if (path.startsWith("/assets/") || path.startsWith("/auth") || path.equals("/login")) {
            chain.doFilter(request, response);
            return;
        }

        // 2. Vérification de la session utilisateur
        HttpSession session = req.getSession(false);
        Utilisateur user = (session != null) ? (Utilisateur) session.getAttribute("user") : null;

        if (user == null) {
            res.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        // 3. Contrôle d'accès basé sur les rôles (RBAC)
        Role role = user.getRole();

        if (path.startsWith("/infirmier") && role != Role.INFIRMIER && role != Role.ADMINISTRATEUR) {
            res.sendError(HttpServletResponse.SC_FORBIDDEN, "Accès refusé : Rôle Infirmier requis.");
            return;
        }

        if (path.startsWith("/generaliste") && role != Role.GENERALISTE && role != Role.ADMINISTRATEUR) {
            res.sendError(HttpServletResponse.SC_FORBIDDEN, "Accès refusé : Rôle Généraliste requis.");
            return;
        }

        if (path.startsWith("/specialiste") && role != Role.SPECIALISTE && role != Role.ADMINISTRATEUR) {
            res.sendError(HttpServletResponse.SC_FORBIDDEN, "Accès refusé : Rôle Spécialiste requis.");
            return;
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}