/**
  * @title   Certificate Contract
  * @author  Rosen HCMC Lab
  *
  * Each instance of this contract represents a single certificate.
  */
contract OrganizationalCertification  {

    /**
      * Address of CertificatioRegistry contract this certificate belongs to.
      */
    address public registryAddress;

    string public CompanyName;
    string public Standard;
    string public CertificateId;
    string public IssueDate;
    string public ExpireDate;
    string public Scope;
    string public CertificationBodyName;

    /**
      * Constructor.
      *
      * @param _CompanyName Name of company name the certificate is IssueDate to.
      * @param _Standard The Standard.
      * @param _CertificateId Unique identifier of the certificate.
      * @param _IssueDate Timestamp (Unix epoch) when the certificate was IssueDate.
      * @param _ExpireDate Timestamp (Unix epoch) when the certificate will expire.
      * @param _Scope The scope of the certificate.
      * @param _CertificationBodyName The issuer of the certificate.
      */
    constructor(
        string memory _CompanyName,
        string memory _Standard,
        string memory _CertificateId,
        string memory _IssueDate,
        string memory _ExpireDate,
        string memory _Scope,
        string memory _CertificationBodyName)
        public
    {
        registryAddress = msg.sender;
        CompanyName = _CompanyName;
        Standard = _Standard;
        CertificateId = _CertificateId;
        IssueDate = _IssueDate;
        ExpireDate = _ExpireDate;
        Scope = _Scope;
        CertificationBodyName = _CertificationBodyName;
    }

    function updateCertificate(
        string memory _CompanyName,
        string memory _Standard,
        string memory _IssueDate,
        string memory _ExpireDate,
        string memory _Scope)
        public
        onlyRegistry
    {
        CompanyName = _CompanyName;
        Standard = _Standard;
        IssueDate = _IssueDate;
        ExpireDate = _ExpireDate;
        Scope = _Scope;
    }

    function changeRegistry(address newRegistryAddress)
        public
        onlyRegistry
    {
        registryAddress = newRegistryAddress;
    }

    modifier onlyRegistry() {
        require(msg.sender == registryAddress, "Call invoked from incorrect address");
        _;
    }
    /**
      * Extinguish this certificate.
      *
      * This can be done the same certifier contract which has created
      * the certificate in the first place only.
      */
    function deleteCertificate() public onlyRegistry {
        selfdestruct(msg.sender);
    }

}