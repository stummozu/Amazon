package Amazon.business.impl;

import org.springframework.stereotype.Service;

import Amazon.business.RoleService;
import Amazon.business.model.Role;

@Service
public class JPARoleService extends JPACRUDService<Long, Role> implements RoleService {

}
