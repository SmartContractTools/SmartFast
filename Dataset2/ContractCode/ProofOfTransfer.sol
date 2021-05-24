// File: browser/flattened.sol


// File: browser/DateTime.sol

pragma solidity >=0.4.21 <0.6.0;

contract DateTime {
        /*
         *  Date and Time utilities for ethereum contracts
         *
         */
        struct _DateTime {
                uint16 year;
                uint8 month;
                uint8 day;
                uint8 hour;
                uint8 minute;
                uint8 second;
                uint8 weekday;
        }

        uint constant DAY_IN_SECONDS = 86400;
        uint constant YEAR_IN_SECONDS = 31536000;
        uint constant LEAP_YEAR_IN_SECONDS = 31622400;

        uint constant HOUR_IN_SECONDS = 3600;
        uint constant MINUTE_IN_SECONDS = 60;

        uint16 constant ORIGIN_YEAR = 1970;

        function isLeapYear(uint16 year) internal pure returns (bool) {
                if (year % 4 != 0) {
                        return false;
                }
                if (year % 100 != 0) {
                        return true;
                }
                if (year % 400 != 0) {
                        return false;
                }
                return true;
        }

        function leapYearsBefore(uint year) internal pure returns (uint) {
                year -= 1;
                return year / 4 - year / 100 + year / 400;
        }

        function getDaysInMonth(uint8 month, uint16 year) internal pure returns (uint8) {
                if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
                        return 31;
                }
                else if (month == 4 || month == 6 || month == 9 || month == 11) {
                        return 30;
                }
                else if (isLeapYear(year)) {
                        return 29;
                }
                else {
                        return 28;
                }
        }

        function parseTimestamp(uint timestamp) internal pure returns (_DateTime memory dt) {
                uint secondsAccountedFor = 0;
                uint buf;
                uint8 i;

                // Year
                dt.year = getYear(timestamp);
                buf = leapYearsBefore(dt.year) - leapYearsBefore(ORIGIN_YEAR);

                secondsAccountedFor += LEAP_YEAR_IN_SECONDS * buf;
                secondsAccountedFor += YEAR_IN_SECONDS * (dt.year - ORIGIN_YEAR - buf);

                // Month
                uint secondsInMonth;
                for (i = 1; i <= 12; i++) {
                        secondsInMonth = DAY_IN_SECONDS * getDaysInMonth(i, dt.year);
                        if (secondsInMonth + secondsAccountedFor > timestamp) {
                                dt.month = i;
                                break;
                        }
                        secondsAccountedFor += secondsInMonth;
                }

                // Day
                for (i = 1; i <= getDaysInMonth(dt.month, dt.year); i++) {
                        if (DAY_IN_SECONDS + secondsAccountedFor > timestamp) {
                                dt.day = i;
                                break;
                        }
                        secondsAccountedFor += DAY_IN_SECONDS;
                }

                // Hour
                dt.hour = getHour(timestamp);

                // Minute
                dt.minute = getMinute(timestamp);

                // Second
                dt.second = getSecond(timestamp);

                // Day of week.
                dt.weekday = getWeekday(timestamp);
        }

        function getYear(uint timestamp) internal pure returns (uint16) {
                uint secondsAccountedFor = 0;
                uint16 year;
                uint numLeapYears;

                // Year
                year = uint16(ORIGIN_YEAR + timestamp / YEAR_IN_SECONDS);
                numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);

                secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
                secondsAccountedFor += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - numLeapYears);

                while (secondsAccountedFor > timestamp) {
                        if (isLeapYear(uint16(year - 1))) {
                                secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
                        }
                        else {
                                secondsAccountedFor -= YEAR_IN_SECONDS;
                        }
                        year -= 1;
                }
                return year;
        }

        function getMonth(uint timestamp) internal pure returns (uint8) {
                return parseTimestamp(timestamp).month;
        }

        function getDay(uint timestamp) internal pure returns (uint8) {
                return parseTimestamp(timestamp).day;
        }

        function getHour(uint timestamp) internal pure returns (uint8) {
                return uint8((timestamp / 60 / 60) % 24);
        }

        function getMinute(uint timestamp) internal pure returns (uint8) {
                return uint8((timestamp / 60) % 60);
        }

        function getSecond(uint timestamp) internal pure returns (uint8) {
                return uint8(timestamp % 60);
        }

        function getWeekday(uint timestamp) internal pure returns (uint8) {
                return uint8((timestamp / DAY_IN_SECONDS + 4) % 7);
        }

        function toTimestamp(uint16 year, uint8 month, uint8 day) internal pure returns (uint timestamp) {
                return toTimestamp(year, month, day, 0, 0, 0);
        }

        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour) internal pure returns (uint timestamp) {
                return toTimestamp(year, month, day, hour, 0, 0);
        }

        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute) internal pure returns (uint timestamp) {
                return toTimestamp(year, month, day, hour, minute, 0);
        }

        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute, uint8 second) internal pure returns (uint timestamp) {
                uint16 i;

                // Year
                for (i = ORIGIN_YEAR; i < year; i++) {
                        if (isLeapYear(i)) {
                                timestamp += LEAP_YEAR_IN_SECONDS;
                        }
                        else {
                                timestamp += YEAR_IN_SECONDS;
                        }
                }

                // Month
                uint8[12] memory monthDayCounts;
                monthDayCounts[0] = 31;
                if (isLeapYear(year)) {
                        monthDayCounts[1] = 29;
                }
                else {
                        monthDayCounts[1] = 28;
                }
                monthDayCounts[2] = 31;
                monthDayCounts[3] = 30;
                monthDayCounts[4] = 31;
                monthDayCounts[5] = 30;
                monthDayCounts[6] = 31;
                monthDayCounts[7] = 31;
                monthDayCounts[8] = 30;
                monthDayCounts[9] = 31;
                monthDayCounts[10] = 30;
                monthDayCounts[11] = 31;

                for (i = 1; i < month; i++) {
                        timestamp += DAY_IN_SECONDS * monthDayCounts[i - 1];
                }

                // Day
                timestamp += DAY_IN_SECONDS * (day - 1);

                // Hour
                timestamp += HOUR_IN_SECONDS * (hour);

                // Minute
                timestamp += MINUTE_IN_SECONDS * (minute);

                // Second
                timestamp += second;

                return timestamp;
        }
}

// File: browser/Dependency.sol

pragma solidity >=0.4.21 <0.6.0;


contract Dependency is DateTime 
{ 
  /**
   * @dev struture to store File transfer related information
   */
    struct FileProof
    {
        address sender;
        address receiver;
        bytes32 fileHash;
        uint256 timestamp;
        bytes32 QR;
        bytes32 QRTime;
    }
  /**
   * @dev structure to store Folder transfer related information
   */
    struct FolderProof
    {
        address sender;
        address receiver;
        address folderAddress;
        bytes32 folderHash;
        uint256 timestamp;
        bytes32 QR;
        bytes32 QRTime;
    }

    struct FileQRWithIndex
    {
        bytes32 hashFile;
        uint256 index;
    }

    struct FolderQRWithIndex
    {
        address folderAddress;
        uint256 index;
    }

  /**
   * @dev mapping to map the proof and QR codes(both with and Without time)
   * @mapping fileProofs , map the struct of file proof with file hash as its key
   * @mapoing folderProofs , map the struct of folder proof with folder hash as its key
   * @mapping fileQrCodeWithoutTime , map the QR code with file  hash as key . It helps in searching proof via QR
   * @mapping fileQrCodeWithTime , map the QR code with Time with file hash as key   
   * @mapping folderQrCodeWithoutTime , map the QR code with folder address as key . It helps in searching proof via QR
   * @mapping folderQrCodeWithTime , map the QR code with Time with folder address as key   
   */
    mapping (bytes32 => FileProof[]) fileProofs; // this allows to look up proof of transfer by the hashfile
    mapping (address => FolderProof[]) folderProofs;
    mapping (bytes32 => FileQRWithIndex[]) fileQrCodeWithoutTime; //  QrCode => hashFile
    mapping (bytes32 => FileQRWithIndex[]) fileQrCodeWithTime;
    mapping (bytes32 => FolderQRWithIndex[]) folderQrCodeWithoutTime; //  QrCode => hashFile
    mapping (bytes32 => FolderQRWithIndex[]) folderQrCodeWithTime;

    mapping(bytes32 => bool)  usedFileHashes;
    mapping(address => bool)  usedFolderAddresses;


    /**
     * @dev supporting function for creating and storing Transfer proof 
     */

    function _inCreateFileTransferProof(address _sender, address _receiver, bytes32 _fileHash,uint256 time, bytes32 QRWithNoTime ,bytes32 QRWithTime) internal returns (bool)
    {
        FileProof memory currentInfo;
        currentInfo.sender = _sender;
        currentInfo.receiver = _receiver;
        currentInfo.fileHash = _fileHash;
        currentInfo.timestamp = time;
        currentInfo.QR = QRWithNoTime;
        currentInfo.QRTime = QRWithTime;
        // if the entry is already present in mapping with same File Proof then it add the info in the array of struct "FileProof" mapped to the specific file hash,
        // And if not present then creates the new entry
        fileProofs[_fileHash].push(currentInfo);
        uint256 index = fileProofs[_fileHash].length - 1;
        FileQRWithIndex memory indexInfo;
        indexInfo.hashFile = _fileHash;
        indexInfo.index = index;
        fileQrCodeWithoutTime[QRWithNoTime].push(indexInfo);
        fileQrCodeWithTime[QRWithTime].push(indexInfo);
        usedFileHashes[_fileHash] = true;
        return true;
    }


    /**
     * @dev supporting function for creating and storing Folder transfer proof
     */
    function _inCreateFolderTransferProof(address _sender,address _receiver,address _folderAddress,bytes32 _folderHash,uint256 time,bytes32 QRWithNoTime,bytes32 QRWithTime) internal returns(bool)
    {
        FolderProof memory currentInfo;
        currentInfo.sender = _sender;
        currentInfo.receiver = _receiver;
        currentInfo.folderAddress = _folderAddress;
        currentInfo.folderHash = _folderHash;
        currentInfo.timestamp = time;
        currentInfo.QR = QRWithNoTime;
        currentInfo.QRTime = QRWithTime;
        // if the entry is already present in mapping with same folder address then it add the info in the array of struct "FolderProof" mapped to the specific address,
        // And if not present then creates the new entry
        folderProofs[_folderAddress].push(currentInfo); 
        uint256 index = folderProofs[_folderAddress].length - 1;
        FolderQRWithIndex memory indexInfo;
        indexInfo.folderAddress = _folderAddress;
        indexInfo.index = index;
        folderQrCodeWithoutTime[QRWithNoTime].push(indexInfo);
        folderQrCodeWithTime[QRWithTime].push(indexInfo);
        usedFolderAddresses[_folderAddress] = true;
        return true;
    }


    /**
     * @dev returns array of all senders and receivers related to supplied file hash
     */
    function _inGetFileTransferProofs(bytes32 fileHash, uint256 index) internal view returns (address[] memory, bytes32, bool)
    {   
        address[] memory senderAndReceiver = new address[](2);
        senderAndReceiver[0] = fileProofs[fileHash][index].sender;
        senderAndReceiver[1] = fileProofs[fileHash][index].receiver;
        bytes32 QR = fileProofs[fileHash][index].QR;
        if(fileProofs[fileHash].length - 1 > index)
        {
            return(senderAndReceiver, QR, true);
        }
        else
        {
            return(senderAndReceiver, QR, false);
        }
    }


    /**
   * @dev calculates the day , month , year using the timestamp
   * @param time , timestamp whose day,month,year is to be calculated 
   */
    function getDateTime (uint256 time) internal pure returns(uint256,uint256,uint256)
      {
        uint256 year = getYear(time);
        uint256 month = getMonth(time);
        uint256 day = getDay(time);
        return (year, month, day );
    }


    /**
     * @dev returns array of all day , month , year related to supplied file hash  
     */
    function _inGetFileTransferProofsDateTime(bytes32 fileHash,uint256 index ,uint256 len) internal view returns (address[] memory, bytes32, uint256[] memory,bool)
    {     
        uint256 time = fileProofs[fileHash][index].timestamp; 
        (uint256 year, uint256 month, uint256 day) = getDateTime(time);
        address[] memory senderAndReceiver = new address[](2);
        senderAndReceiver[0] = fileProofs[fileHash][index].sender;
        senderAndReceiver[1] = fileProofs[fileHash][index].receiver;
        bytes32 QR = fileProofs[fileHash][index].QRTime;
        uint256[] memory Date = new uint256[](3);
        Date[0] = day;
        Date[1] = month;
        Date[2] = year;
        if(len - 1 > index)
        {
            return(senderAndReceiver, QR, Date, true);
        }
        else
        {
            return(senderAndReceiver, QR, Date, false);
        }
    }


    /**
     * @dev returns array of all senders and receivers related to supplied folder Address  
     */


    function _inGetFolderTransferProofs(address folderAddress,uint256 index) internal view returns(address[] memory,bytes32 , bytes32, bool)
    {   
        address[] memory senderAndReceiver = new address[](2);
        senderAndReceiver[0] = folderProofs[folderAddress][index].sender;
        senderAndReceiver[1] = folderProofs[folderAddress][index].receiver;
        bytes32 QR = folderProofs[folderAddress][index].QR;
        bytes32 folderHash = folderProofs[folderAddress][index].folderHash;
        if(folderProofs[folderAddress].length - 1 > index)
        {
            return(senderAndReceiver,folderHash, QR, true);
        }
        else
        {
            return(senderAndReceiver,folderHash,QR, false);
        }
    }


    /**
     * @dev returns array of all day , month , year related to supplied folder address 
     */
    function _inGetFolderTransferProofsWithDateTime(address folderAddress,uint256 index, uint256 len) internal view returns (address[] memory,bytes32,bytes32, uint256[] memory,bool)
    {   
        uint256 time = folderProofs[folderAddress][index].timestamp; 
       // (uint256 year, uint256 month, uint256 day) = getDateTime(time);
        address[] memory senderAndReceiver = new address[](2);
        senderAndReceiver[0] = folderProofs[folderAddress][index].sender;
        senderAndReceiver[1] = folderProofs[folderAddress][index].receiver;
        bytes32 folderHash = folderProofs[folderAddress][index].folderHash;
        bytes32 QR = folderProofs[folderAddress][index].QRTime;
        uint256[] memory Date = new uint256[](3);
        (Date[2],Date[1],Date[0])= getDateTime(time);
        if(len - 1 > index)
        {
            return(senderAndReceiver,folderHash ,QR,Date, true);
        }
        else
        {
            return(senderAndReceiver,folderHash, QR,Date, false);
        }
    }
    

    /**
     * @dev supporting function for searching file information via QR code 
     */
    function _InSearchFileTransferProof(bytes32 QRCode) internal view returns(address , address , bytes32)
      {
        bytes32 Hash;
        Hash = fileQrCodeWithoutTime[QRCode][0].hashFile;
        require(fileExists(Hash),"file does not exists");
        uint256 index = fileQrCodeWithoutTime[QRCode][0].index;
        address sender = fileProofs[Hash][index].sender;
        address receiver = fileProofs[Hash][index].receiver;
        return (sender, receiver, Hash);
    }


    /**
     * @dev supporting function for searching file information with day , month , year via QR code 
     */
    function _InSearchFileTransferProofWithTime(bytes32 QRCode) internal view returns(address , address , uint256 , uint256 , uint256 ,bytes32)
    {
        bytes32 Hash;
        Hash = fileQrCodeWithTime[QRCode][0].hashFile;
        require(fileExists(Hash),"file does not exists");
        uint256 index = fileQrCodeWithTime[QRCode][0].index;
        address sender = fileProofs[Hash][index].sender;
        address receiver = fileProofs[Hash][index].receiver;
        (uint256 year, uint256 month, uint256 day) = getDateTime(fileProofs[Hash][index].timestamp);
        return (sender, receiver, day, month, year, Hash);
    }


    /**
     * @dev supporting function for searching folder information  via QR code 
     */
    function _InSearchFolderTransferProof(bytes32 QRCode) internal view returns(address , address , address , bytes32)
    {
        address folderAddress;
        folderAddress = folderQrCodeWithoutTime[QRCode][0].folderAddress;
        require(folderExists(folderAddress), "folder does not exist");
        uint256 index = folderQrCodeWithoutTime[QRCode][0].index;
        address sender = folderProofs[folderAddress][index].sender;
        address receiver = folderProofs[folderAddress][index].receiver;
        bytes32 folderHash = folderProofs[folderAddress][index].folderHash;
        return (sender, receiver, folderAddress , folderHash);
    }


    /**
     * @dev supporting function for searching folder information with day , month , year via QR code    
     */
    function _InSearchFolderTransferProofWithTime(bytes32 QRCode) internal view returns(address ,address , address , bytes32,uint256 , uint256 , uint256)
    {
        address folderAddress;
        folderAddress = folderQrCodeWithTime[QRCode][0].folderAddress;
        require(folderExists(folderAddress), "folder does not exist");
        uint256 index = folderQrCodeWithTime[QRCode][0].index;
        address sender = folderProofs[folderAddress][index].sender;
        address receiver = folderProofs[folderAddress][index].receiver;
        bytes32 folderHash = folderProofs[folderAddress][index].folderHash;
        (uint256 year, uint256 month, uint256 day) = getDateTime(folderProofs[folderAddress][index].timestamp);
        return (sender, receiver, folderAddress,folderHash, day, month, year);
    }


    /**
     * @dev checks file exists or not , using File Hash
     */
    function fileExists(bytes32 fileHash)internal view  returns (bool)
    {
        bool exists = false;
        if (usedFileHashes[fileHash])
        {
            exists = true;
        }
        return exists;
    }
  

    /**
     * @dev checks folder exists or not , using folder addressn
     */
    function folderExists(address folderAddress) internal view  returns (bool)
    {
        bool exists = false;
        if (usedFolderAddresses[folderAddress])
        {
            exists = true;
        }
  
        return exists;
    }
    
}

// File: browser/ProofOfTransfer.sol

pragma solidity >=0.4.21 <0.6.0;


contract ProofOfTransfer is Dependency
{ 

  /**
   * @dev Creates and stores the File transfer proof at the block timestamp
   * timestamp in stored as no minor change in time shall be there at time of storing and creting QR hash
   * @param _sender , represents the entity who is sending the file
   * @param _receiver , represents the entity who is receiving the file 
   * @param _fileHash , hash of file being transferred
   * @return bool , true if creates the file transfer proof entry successfully
   */
    function createFileTransferProof(address _sender, address _receiver, bytes32 _fileHash) public returns (bool)
    {
        uint256 time = block.timestamp;
        bytes32 QRWithNoTime = getQRCodeForFile(_sender, _receiver, _fileHash, 0);
        bytes32 QRWithTime = getQRCodeForFile(_sender, _receiver,_fileHash, time);
        return _inCreateFileTransferProof(_sender,_receiver,_fileHash,time,QRWithNoTime,QRWithTime);
    }


      /**
   * @dev Creates and stores the Folder transfer proof at the block timestamp
   * @param _sender , represents the entity who is sending folder
   * @param _receiver , represents the entity who is receiving folder
   * @param _folderAddress , address of folder which is being send
   * @return bool , true if creates the fiolder transfer proof entry successfully
   */
    function createFolderTransferProof(address _sender, address _receiver, address _folderAddress , bytes32 folderHash ) public returns(bool)
    { 
        uint256 time = block.timestamp;
        bytes32 QRWithNoTime = getQRCodeForFolder(_sender, _receiver, _folderAddress,folderHash, 0);
        bytes32 QRWithTime = getQRCodeForFolder(_sender, _receiver, _folderAddress,folderHash, time);
        return _inCreateFolderTransferProof(_sender,_receiver,_folderAddress,folderHash,time,QRWithNoTime,QRWithTime);        
    }


 /**
   * @dev get file transfer proof by using filehash
   * @param fileHash , hash of file , whose information is to be fetched
   * @return , address of sender , reciever and QR code 
   */
    function getFileTransferProofs(bytes32 fileHash, uint256 Index) public view returns(address[] memory,bytes32,bool)
    {   
        require(fileExists(fileHash),"No file found");
        (address[] memory senderAndReceiver,bytes32 QR,bool nextIndexPresent) = _inGetFileTransferProofs(fileHash, Index);
        return (senderAndReceiver,QR,nextIndexPresent);
    }


  /**
    * @dev get file transfer proof with time detail by using filehash
    * @param fileHash , hash of file , whose information is to be fetched
    * @return , address of sender , reciever and QR code with day ,month and year information also
    */
    function getFileTransferProofWithTDateTime(bytes32 fileHash, uint256 Index) public view returns(address[] memory,bytes32, uint256[] memory,bool)
    {
        require(fileExists(fileHash),"No file found");
        //sending length in this function to remove "STACK TOO DEEEP ERROR" 
        uint256 len = fileProofs[fileHash].length;
        (address[] memory senderAndReceiver,bytes32 QR,uint256[] memory Date,bool nextIndexPresent) = _inGetFileTransferProofsDateTime(fileHash, Index ,len);
        return (senderAndReceiver,QR,Date,nextIndexPresent);
    }
    

    /**
   * @dev get folder transfer proof by using folder address
   * @param folderAddress , address of folder , whose information is to be fetched
   * @return , address of sender , reciever and QR code 
   */
    function getFolderTransferProofs(address folderAddress, uint256 Index) public view returns (address[] memory, bytes32,bytes32,bool)
    {   
        require(folderExists(folderAddress),"No folder found");
        (address[] memory senderAndReceiver ,bytes32 folderHash,bytes32 QR,bool nextIndexPresent) = _inGetFolderTransferProofs(folderAddress, Index); 
        return (senderAndReceiver,folderHash,QR,nextIndexPresent);
    }


  /**
   * @dev get folder transfer proof by using folder address with date time details
   * @param folderAddress , address of folder , whose information is to be fetched
   * @return , address of sender , reciever and QR code with day ,month and year information also
   */
    function getFolderTransferProofsWithDateTime(address folderAddress , uint256 Index) public view returns(address[] memory, bytes32,bytes32, uint256[] memory,bool)
    {
        require(folderExists(folderAddress),"No folder found");
        //sending length in this function to remove "STACK TOO DEEEP ERROR" 
        uint256 len = folderProofs[folderAddress].length;
        (address[] memory senderAndReceiver, bytes32 folderHash,bytes32 QR,uint256[] memory Date,bool nextIndexPresent) = _inGetFolderTransferProofsWithDateTime(folderAddress, Index, len);
        return (senderAndReceiver,folderHash,QR,Date,nextIndexPresent);
    }

  /**
   * @dev search file transfer proof using QR code
   * @param QRCode , whose information is to be fetched
   * @return , address of sender, reciever and fileHash
   */
    function SearchFileTransferProof(bytes32 QRCode) public view returns(address , address ,bytes32)
    {
        return _InSearchFileTransferProof(QRCode);
    }


  /**
   * @dev search file transfer proof using QR code with time details
   * @param QRCodeTime , whose information is to be fetched
   * @return , address of sender, reciever and fileHash with day ,month and year information also
   */
    function SearchFileTransferProofWithTime(bytes32 QRCodeTime) public view returns(address , address , uint256 , uint256 , uint256 ,bytes32)
    {
        return _InSearchFileTransferProofWithTime(QRCodeTime);
    }


   /**
   * @dev search folder transfer proof using QR code 
   * @param QRCode , whose information is to be fetched
   * @return , address of sender, reciever and address of the folder
   */
    function SearchFolderTransferProof(bytes32 QRCode) public view returns(address , address , address , bytes32)
    {
        return _InSearchFolderTransferProof(QRCode);
    }

   /**
   * @dev search folder transfer proof using QR code with time details
   * @param QRCodeTime , whose information is to be fetched
   * @return , address of sender, reciever and address of the folder with day ,month and year information also
   */
    function SearchFolderTransferProofWithTime(bytes32 QRCodeTime) public view returns(address ,address , address, bytes32 , uint256 , uint256 , uint256)
    {
        return _InSearchFolderTransferProofWithTime(QRCodeTime);
    }     


  /**
   * @dev generates the QR code using filehash ,etc
   * Can generate QR code with time and without time
   */
    function getQRCodeForFile (address _sender, address _receiver,bytes32 fileHash, uint256 timestamp) internal pure returns (bytes32)
    {
        bytes32 QRCodeHash;

        if(timestamp == 0)  //generate QR code without dateTime
        {
            QRCodeHash = keccak256(abi.encodePacked(_sender, _receiver,fileHash));
        }
        else 
        {
            (uint256 year, uint256 month, uint256 day) = getDateTime(timestamp);
            QRCodeHash = keccak256(abi.encodePacked(_sender, _receiver, fileHash, day, month, year));
        }

        return QRCodeHash;
    }


  /**
   * @dev generates the QR code using Folder address , etc 
   * Can generate QR code with time and without time
   */
    function getQRCodeForFolder (address _sender, address _receiver,address folderAddress,bytes32 folderHash, uint256 timestamp) internal pure returns (bytes32)
    {
        bytes32 QRCodeHash;

        if(timestamp == 0)  //generate QR code without dateTime
        {
            QRCodeHash = keccak256(abi.encodePacked(_sender, _receiver,folderAddress , folderHash));
        }
        else 
        {
            (uint256 year, uint256 month, uint256 day) = getDateTime(timestamp);
            QRCodeHash = keccak256(abi.encodePacked(_sender, _receiver,folderAddress,folderHash,day,month, year));
        }

        return QRCodeHash;
    }

}