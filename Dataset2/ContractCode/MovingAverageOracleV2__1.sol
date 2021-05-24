// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.5.2;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// File: contracts/meta-oracles/lib/TimeSeriesStateLibrary.sol

/*
    Copyright 2019 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity 0.5.7;


/**
 * @title TimeSeriesStateLibrary
 * @author Set Protocol
 *
 * Library defining TimeSeries state struct
 */
library TimeSeriesStateLibrary {
    struct State {
        uint256 nextEarliestUpdate;
        uint256 updateInterval;
        uint256[] timeSeriesDataArray;
    }
}

// File: contracts/meta-oracles/interfaces/ITimeSeriesFeed.sol

/*
    Copyright 2019 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity 0.5.7;


/**
 * @title ITimeSeriesFeed
 * @author Set Protocol
 *
 * Interface for interacting with TimeSeriesFeed contract
 */
interface ITimeSeriesFeed {

    /*
     * Query linked list for specified days of data. Will revert if number of days
     * passed exceeds amount of days collected.
     *
     * @param  _dataDays            Number of dats of data being queried
     */
    function read(
        uint256 _dataDays
    )
        external
        view
        returns (uint256[] memory);

    function nextEarliestUpdate()
        external
        view
        returns (uint256);

    function updateInterval()
        external
        view
        returns (uint256);

    function getTimeSeriesFeedState()
        external
        view
        returns (TimeSeriesStateLibrary.State memory);
}

// File: contracts/meta-oracles/MovingAverageOracleV2.sol

/*
    Copyright 2019 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity 0.5.7;
pragma experimental "ABIEncoderV2";




/**
 * @title MovingAverageOracleV2
 * @author Set Protocol
 *
 * Contract used calculate moving average of data points provided by other on-chain
 * price feed and return to querying contract.
 * CHANGELOG:
 *  - Updated from version one to read from ITimeSeriesFeed
 *  - Outputs uint256 instead of bytes
 *  - getSourceMedianizer() function removed.
 */
contract MovingAverageOracleV2 {

    using SafeMath for uint256;

    /* ============ State Variables ============ */
    string public dataDescription;
    ITimeSeriesFeed public timeSeriesFeedInstance;

    /* ============ Constructor ============ */

    /*
     * MovingAverageOracleV2 constructor.
     * Contract used calculate moving average of data points provided by other on-chain
     * price feed and return to querying contract
     *
     * @param  _timeSeriesFeed          TimeSeriesFeed to get list of data from
     * @param  _dataDescription         Description of data
     */
    constructor(
        ITimeSeriesFeed _timeSeriesFeed,
        string memory _dataDescription
    )
        public
    {
        timeSeriesFeedInstance = _timeSeriesFeed;

        dataDescription = _dataDescription;
    }

    /*
     * Get moving average over defined amount of data points by querying price feed and
     * averaging returned data. Returns uint256.
     *
     * @param  _dataPoints       Number of data points to create average from
     * @returns                  Moving average for passed number of _dataPoints
     */
    function read(
        uint256 _dataPoints
    )
        external
        view
        returns (uint256)
    {
        // Get data from price feed
        uint256[] memory dataArray = timeSeriesFeedInstance.read(_dataPoints);

        // Sum data retrieved from daily price feed
        uint256 dataSum = 0;
        for (uint256 i = 0; i < dataArray.length; i++) {
            dataSum = dataSum.add(dataArray[i]);
        }

        // Return average price
        return dataSum.div(_dataPoints);
    }
}