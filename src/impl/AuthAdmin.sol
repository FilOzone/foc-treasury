pragma solidity ^0.8.33;

import {TreasuryAuth} from "../TreasuryAuth.sol";

contract AppointAdministrator is TreasuryAuth {
    function appointAdministrator(address admin) external onlyAdmin {
        appoint(admin, ADMIN);
    }
}

contract DismissAdministrator is TreasuryAuth {
    function dismissAdministrator(address admin) external onlyAdmin {
        dismiss(admin, ADMIN);
    }
}

contract AppointTreasurer is TreasuryAuth {
    function appointTreasurer(address admin) external onlyAdmin {
        appoint(admin, TREASURER);
    }
}

contract DismissTreasurer is TreasuryAuth {
    function dismissTreasurer(address admin) external onlyAdmin {
        dismiss(admin, TREASURER);
    }
}
