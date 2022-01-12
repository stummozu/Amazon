package Amazon.common.spring.session;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.session.SessionRegistry;
import org.springframework.stereotype.Service;

import Amazon.business.model.User;
import Amazon.common.spring.security.UserDetailsImpl;

@Service
public class SessionService {
   @Autowired
   private SessionRegistry sessionRegistry;
   
   public void expireUserSession(User user) {
      sessionRegistry.getAllPrincipals().forEach(principal -> {
         if (principal instanceof UserDetailsImpl && ((UserDetailsImpl) principal).getUser().getId().equals(user.getId())){
            sessionRegistry.getAllSessions(principal, false).forEach(userSession -> {
               userSession.expireNow();
            });
         }
      });
   }
   
   public void updateUserSession(User user) {
      sessionRegistry.getAllPrincipals().forEach(principal -> {
         if (principal instanceof UserDetailsImpl && ((UserDetailsImpl) principal).getUser().getId().equals(user.getId())){
            ((UserDetailsImpl) principal).setUser(user);
            sessionRegistry.getAllSessions(principal, false).forEach(userSession -> {
               ((UserDetailsImpl) userSession.getPrincipal()).setUser(user);
            });
         }
      });
   }
  
}
