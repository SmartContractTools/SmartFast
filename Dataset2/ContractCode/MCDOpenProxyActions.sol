pragma solidity ^0.5.0;

contract GemLike {
    function approve(address, uint) public;
    function transfer(address, uint) public;
    function transferFrom(address, address, uint) public;
    function deposit() public payable;
    function withdraw(uint) public;
}

contract ManagerLike {
    function cdpCan(address, uint, address) public view returns (uint);
    function ilks(uint) public view returns (bytes32);
    function owns(uint) public view returns (address);
    function urns(uint) public view returns (address);
    function vat() public view returns (address);
    function open(bytes32, address) public returns (uint);
    function give(uint, address) public;
    function cdpAllow(uint, address, uint) public;
    function urnAllow(address, uint) public;
    function frob(uint, int, int) public;
    function flux(uint, address, uint) public;
    function move(uint, address, uint) public;
    function exit(address, uint, address, uint) public;
    function quit(uint, address) public;
    function enter(address, uint) public;
    function shift(uint, uint) public;
}

contract VatLike {
    function can(address, address) public view returns (uint);
    function ilks(bytes32) public view returns (uint, uint, uint, uint, uint);
    function dai(address) public view returns (uint);
    function urns(bytes32, address) public view returns (uint, uint);
    function frob(bytes32, address, address, address, int, int) public;
    function hope(address) public;
    function move(address, address, uint) public;
}

contract GemJoinLike {
    function dec() public returns (uint);
    function gem() public returns (GemLike);
    function join(address, uint) public payable;
    function exit(address, uint) public;
}

contract GNTJoinLike {
    function bags(address) public view returns (address);
    function make(address) public returns (address);
}

contract DaiJoinLike {
    function vat() public returns (VatLike);
    function dai() public returns (GemLike);
    function join(address, uint) public payable;
    function exit(address, uint) public;
}

contract HopeLike {
    function hope(address) public;
    function nope(address) public;
}

contract ProxyRegistryInterface {
    function build(address) public returns (address);
}

contract EndLike {
    function fix(bytes32) public view returns (uint);
    function cash(bytes32, uint) public;
    function free(bytes32) public;
    function pack(uint) public;
    function skim(bytes32, address) public;
}

contract JugLike {
    function drip(bytes32) public returns (uint);
}

contract PotLike {
    function pie(address) public view returns (uint);
    function drip() public returns (uint);
    function join(uint) public;
    function exit(uint) public;
}

contract ProxyRegistryLike {
    function proxies(address) public view returns (address);
    function build(address) public returns (address);
}

contract ProxyLike {
    function owner() public view returns (address);
}


// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// WARNING: These functions meant to be used as a a library for a DSProxy. Some are unsafe if you call them directly.
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

contract Common {
    uint256 constant RAY = 10 ** 27;

    // Internal functions

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "mul-overflow");
    }

    // Public functions

    function daiJoin_join(address apt, address urn, uint wad) public {
        // Gets DAI from the user's wallet
        DaiJoinLike(apt).dai().transferFrom(msg.sender, address(this), wad);
        // Approves adapter to take the DAI amount
        DaiJoinLike(apt).dai().approve(apt, wad);
        // Joins DAI into the vat
        DaiJoinLike(apt).join(urn, wad);
    }
}

contract MCDOpenProxyActions is Common {

    // Internal functions

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "sub-overflow");
    }

    function toInt(uint x) internal pure returns (int y) {
        y = int(x);
        require(y >= 0, "int-overflow");
    }

    function toRad(uint wad) internal pure returns (uint rad) {
        rad = mul(wad, 10 ** 27);
    }

    function convertTo18(address gemJoin, uint256 amt) internal returns (uint256 wad) {
        // For those collaterals that have less than 18 decimals precision we need to do the conversion before passing to frob function
        // Adapters will automatically handle the difference of precision
        wad = mul(
            amt,
            10 ** (18 - GemJoinLike(gemJoin).dec())
        );
    }

    function _getDrawDart(
        address vat,
        address jug,
        address urn,
        bytes32 ilk,
        uint wad
    ) internal returns (int dart) {
        // Updates stability fee rate
        uint rate = JugLike(jug).drip(ilk);

        // Gets DAI balance of the urn in the vat
        uint dai = VatLike(vat).dai(urn);

        // If there was already enough DAI in the vat balance, just exits it without adding more debt
        if (dai < mul(wad, RAY)) {
            // Calculates the needed dart so together with the existing dai in the vat is enough to exit wad amount of DAI tokens
            dart = toInt(sub(mul(wad, RAY), dai) / rate);
            // This is neeeded due lack of precision. It might need to sum an extra dart wei (for the given DAI wad amount)
            dart = mul(uint(dart), rate) < mul(wad, RAY) ? dart + 1 : dart;
        }
    }

    function _getWipeDart(
        address vat,
        uint dai,
        address urn,
        bytes32 ilk
    ) internal view returns (int dart) {
        // Gets actual rate from the vat
        (, uint rate,,,) = VatLike(vat).ilks(ilk);
        // Gets actual art value of the urn
        (, uint art) = VatLike(vat).urns(ilk, urn);

        // Uses the whole dai balance in the vat to reduce the debt
        dart = toInt(dai / rate);
        // Checks the calculated dart is not higher than urn.art (total debt), otherwise uses its value
        dart = uint(dart) <= art ? - dart : - toInt(art);
    }

    function _getWipeAllWad(
        address vat,
        address usr,
        address urn,
        bytes32 ilk
    ) internal view returns (uint wad) {
        // Gets actual rate from the vat
        (, uint rate,,,) = VatLike(vat).ilks(ilk);
        // Gets actual art value of the urn
        (, uint art) = VatLike(vat).urns(ilk, urn);
        // Gets actual dai amount in the urn
        uint dai = VatLike(vat).dai(usr);

        uint rad = sub(mul(art, rate), dai);
        wad = rad / RAY;

        // If the rad precision has some dust, it will need to request for 1 extra wad wei
        wad = mul(wad, RAY) < rad ? wad + 1 : wad;
    }

    // Public functions

    function transfer(address gem, address dst, uint wad) public {
        GemLike(gem).transfer(dst, wad);
    }

    function ethJoin_join(address apt, address urn) public payable {
        // Wraps ETH in WETH
        GemJoinLike(apt).gem().deposit.value(msg.value)();
        // Approves adapter to take the WETH amount
        GemJoinLike(apt).gem().approve(address(apt), msg.value);
        // Joins WETH collateral into the vat
        GemJoinLike(apt).join(urn, msg.value);
    }

    function gemJoin_join(address apt, address urn, uint wad, bool transferFrom) public {
        // Only executes for tokens that have approval/transferFrom implementation
        if (transferFrom) {
            // Gets token from the user's wallet
            GemJoinLike(apt).gem().transferFrom(msg.sender, address(this), wad);
            // Approves adapter to take the token amount
            GemJoinLike(apt).gem().approve(apt, wad);
        }
        // Joins token collateral into the vat
        GemJoinLike(apt).join(urn, wad);
    }

    function hope(
        address obj,
        address usr
    ) public {
        HopeLike(obj).hope(usr);
    }

    function nope(
        address obj,
        address usr
    ) public {
        HopeLike(obj).nope(usr);
    }

    function open(
        address manager,
        bytes32 ilk,
        address usr
    ) public returns (uint cdp) {
        cdp = ManagerLike(manager).open(ilk, usr);
    }

    function give(
        address manager,
        uint cdp,
        address usr
    ) public {
        ManagerLike(manager).give(cdp, usr);
    }

    function move(
        address manager,
        uint cdp,
        address dst,
        uint rad
    ) public {
        ManagerLike(manager).move(cdp, dst, rad);
    }

    function frob(
        address manager,
        uint cdp,
        int dink,
        int dart
    ) public {
        ManagerLike(manager).frob(cdp, dink, dart);
    }

    function lockETH(
        address manager,
        address ethJoin,
        uint cdp
    ) public payable {
        // Receives ETH amount, converts it to WETH and joins it into the vat
        ethJoin_join(ethJoin, address(this));
        // Locks WETH amount into the CDP
        VatLike(ManagerLike(manager).vat()).frob(
            ManagerLike(manager).ilks(cdp),
            ManagerLike(manager).urns(cdp),
            address(this),
            address(this),
            toInt(msg.value),
            0
        );
    }

    function lockGem(
        address manager,
        address gemJoin,
        uint cdp,
        uint wad,
        bool transferFrom
    ) public {
        // Takes token amount from user's wallet and joins into the vat
        gemJoin_join(gemJoin, address(this), wad, transferFrom);
        // Locks token amount into the CDP
        VatLike(ManagerLike(manager).vat()).frob(
            ManagerLike(manager).ilks(cdp),
            ManagerLike(manager).urns(cdp),
            address(this),
            address(this),
            toInt(convertTo18(gemJoin, wad)),
            0
        );

    }


    function draw(
        address manager,
        address jug,
        address daiJoin,
        uint cdp,
        uint wad
    ) public {
        address urn = ManagerLike(manager).urns(cdp);
        address vat = ManagerLike(manager).vat();
        bytes32 ilk = ManagerLike(manager).ilks(cdp);
        // Generates debt in the CDP
        frob(manager, cdp, 0, _getDrawDart(vat, jug, urn, ilk, wad));
        // Moves the DAI amount (balance in the vat in rad) to proxy's address
        move(manager, cdp, address(this), toRad(wad));
        // Allows adapter to access to proxy's DAI balance in the vat
        if (VatLike(vat).can(address(this), address(daiJoin)) == 0) {
            VatLike(vat).hope(daiJoin);
        }
        // Exits DAI to the user's wallet as a token
        DaiJoinLike(daiJoin).exit(msg.sender, wad);

    }

    function lockETHAndDraw(
        address manager,
        address jug,
        address ethJoin,
        address daiJoin,
        uint cdp,
        uint wadD
    ) public payable {
        address urn = ManagerLike(manager).urns(cdp);
        address vat = ManagerLike(manager).vat();
        bytes32 ilk = ManagerLike(manager).ilks(cdp);
        // Receives ETH amount, converts it to WETH and joins it into the vat
        ethJoin_join(ethJoin, urn);
        // Locks WETH amount into the CDP and generates debt
        frob(manager, cdp, toInt(msg.value), _getDrawDart(vat, jug, urn, ilk, wadD));
        // Moves the DAI amount (balance in the vat in rad) to proxy's address
        move(manager, cdp, address(this), toRad(wadD));
        // Allows adapter to access to proxy's DAI balance in the vat
        if (VatLike(vat).can(address(this), address(daiJoin)) == 0) {
            VatLike(vat).hope(daiJoin);
        }
        // Exits DAI to the user's wallet as a token
        DaiJoinLike(daiJoin).exit(msg.sender, wadD);
    }

    function openLockETHAndDraw(
        address manager,
        address jug,
        address ethJoin,
        address daiJoin,
        bytes32 ilk,
        uint wadD,
        address owner
    ) public payable returns (uint cdp) {
        cdp = open(manager, ilk, address(this));
        lockETHAndDraw(manager, jug, ethJoin, daiJoin, cdp, wadD);
        give(manager, cdp, owner);

    }

    function lockGemAndDraw(
        address manager,
        address jug,
        address gemJoin,
        address daiJoin,
        uint cdp,
        uint wadC,
        uint wadD,
        bool transferFrom
    ) public {
        address urn = ManagerLike(manager).urns(cdp);
        address vat = ManagerLike(manager).vat();
        bytes32 ilk = ManagerLike(manager).ilks(cdp);
        // Takes token amount from user's wallet and joins into the vat
        gemJoin_join(gemJoin, urn, wadC, transferFrom);
        // Locks token amount into the CDP and generates debt
        frob(manager, cdp, toInt(convertTo18(gemJoin, wadC)), _getDrawDart(vat, jug, urn, ilk, wadD));
        // Moves the DAI amount (balance in the vat in rad) to proxy's address
        move(manager, cdp, address(this), toRad(wadD));
        // Allows adapter to access to proxy's DAI balance in the vat
        if (VatLike(vat).can(address(this), address(daiJoin)) == 0) {
            VatLike(vat).hope(daiJoin);
        }
        // Exits DAI to the user's wallet as a token
        DaiJoinLike(daiJoin).exit(msg.sender, wadD);

    }

    function openLockGemAndDraw(
        address manager,
        address jug,
        address gemJoin,
        address daiJoin,
        bytes32 ilk,
        uint wadC,
        uint wadD,
        bool transferFrom,
        address owner
    ) public returns (uint cdp) {
        cdp = open(manager, ilk, address(this));
        lockGemAndDraw(manager, jug, gemJoin, daiJoin, cdp, wadC, wadD, transferFrom);
        give(manager, cdp, owner);
    }

}