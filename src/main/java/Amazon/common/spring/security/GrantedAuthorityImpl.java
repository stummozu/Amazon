package Amazon.common.spring.security;

import org.springframework.security.core.GrantedAuthority;

import Amazon.business.model.Role;

public class GrantedAuthorityImpl implements GrantedAuthority {
   private static final long serialVersionUID = -6656718807102452484L;
   private Role role;

   public GrantedAuthorityImpl(Role role) {
      super();
      this.role = role;
   }

   @Override
   public String getAuthority() {
      return role.getName();
   }

   @Override
   public String toString() {
      return "[autority=" + role.getName() + "]";
   }
}
