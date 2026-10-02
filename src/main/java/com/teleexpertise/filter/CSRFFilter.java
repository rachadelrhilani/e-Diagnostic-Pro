package com.teleexpertise.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.UUID;

@WebFilter("/*")
public class CSRFFilter implements Filter {

    private static final String CSRF_TOKEN_SESSION_ATTR = "csrfToken";
    private static final String CSRF_TOKEN_PARAM = "_csrf";

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session = req.getSession(true);

        // 1. Générer un token CSRF s'il n'existe pas encore dans la session
        String sessionToken = (String) session.getAttribute(CSRF_TOKEN_SESSION_ATTR);
        if (sessionToken == null) {
            sessionToken = UUID.randomUUID().toString();
            session.setAttribute(CSRF_TOKEN_SESSION_ATTR, sessionToken);
        }

        // 2. Vérifier le token pour toutes les requêtes modifiant l'état (POST, PUT, DELETE)
        String method = req.getMethod();
        if ("POST".equalsIgnoreCase(method) || "PUT".equalsIgnoreCase(method) || "DELETE".equalsIgnoreCase(method)) {
            
            // Ignorer la soumission du formulaire de login si nécessaire
            String path = req.getRequestURI().substring(req.getContextPath().length());
            if (!path.equals("/auth/login") && !path.equals("/login")) {
                
                String requestToken = req.getParameter(CSRF_TOKEN_PARAM);
                if (requestToken == null || !requestToken.equals(sessionToken)) {
                    res.sendError(HttpServletResponse.SC_FORBIDDEN, "Jeton CSRF invalide ou absent.");
                    return;
                }
            }
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}