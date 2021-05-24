# SmartFast, an formal analysis tool for Ethereum smart contracts
<img src="./logo.png" alt="Logo" width="300"/>

SmartFast is a Solidity static analysis framework written in Python 3. It takes the Solidity source code of the smart contract as input, and expresses the source code as SmartIR (XML, IR, and IR-SSA) through a formal description. According to preset rules and taint tracking technology, SmartFast matches SmartIR to locate the contract code with vulnerabilities. In addition, SmartFast can also automatically Optimizationimize contract code and improve the user’s understanding of the contracts.

- [Bugs and Optimizationimizations Detection](#bugs-and-Optimizationimizations-detection)
- [How to Install](#how-to-install)
- [Publications](#publications)

## Bugs and Optimizationimizations Detection

Run SmartFast on a Truffle/Embark/Dapp/Etherlime application:
```bash
SmartFast .
```

Run SmartFast on a single file:
```bash
SmartFast tests/mini_dataset/arbitrary_send.sol
```

Run SmartFast and output the results to a json file:
```bash
SmartFast tests/mini_dataset/arbitrary_send.sol --json tests/expected_json/arbitrary_send.json
```

Run SmartFast and generate a detailed vulnerability audit report (.pdf):
```bash
SmartFast tests/mini_dataset/arbitrary_send.sol --repot tests/report/arbitrary_send.pdf
```

Run SmartFast and generate a streamlined vulnerability audit report (.pdf):
```bash
SmartFast tests/mini_dataset/arbitrary_send.sol --repot-main tests/report/arbitrary_send_main.pdf
```

Use [solc-select](https://github.com/crytic/solc-select) if your contracts require older versions of solc.

### Detectors

Num | Detector | What it Detects | Impact | Confidence
--- | --- | --- | --- | ---
1 | `abiencoderv2-array` | ABI encoding error | High | exactly
2 | `array-by-reference` | Storage parameter usage | High | exactly
3 | `multiple-constructors` | Multiple constructors in a contract | High | exactly
4 | `names-reused` | Check contract name reuse | High | exactly
5 | `public-mappings-nested` | Struct sets the nested structure of struct | High | exactly
6 | `rtlo` | Overwritten from right to left | High | exactly
7 | `shadowing-state` | Check state variable hiding | High | exactly
8 | `suicidal` | Check if anyone can break the contract | High | exactly
9 | `uninitialized-state` | Check for uninitialized state variables | High | exactly
10 | `uninitialized-storage` | Check for uninitialized storage variables | High | exactly
11 | `unprotected-upgrade` | Break the logic of the contract | High | exactly
12 | `visibility` | Check visibility level error | High\Info | exactly
13 | `redundant-fallback` | Check for redundant fallback functions | High\Opt | exactly
14 | `arbitrary-send` | Check if Ether can be sent to any address | High | probably
15 | `continue-in-loop` | Continue causes an infinite loop | High | probably
16 | `controlled-array-length` | Length is allocated directly | High | probably
17 | `controlled-delegatecall` | The delegate address out of control | High | probably
18 | `incorrect-constructor` | Check the constructor name error | High | probably
19 | `parity-multisig-bug` | Check for multi-signature vulnerabilities | High | probably
20 | `reentrancy-eth` | Re-entry vulnerabilities (Ethereum theft) | High | probably
21 | `storage-array` | Signed integer array problem | High | probably
22 | `weak-prng` | Modulo problem of parameters | High | probably
23 | `assert-violation` | Check for incorrect use of assertions | Medium | exactly
24 | `constructor-return` | The use of return in the constructor | Medium | exactly
25 | `enum-conversion` | Scope of enumerated types | Medium | exactly
26 | `erc1155-interface` | Check the wrong ERC1155 interface | Medium | exactly
27 | `erc1410-interface` | Check the wrong ERC1410 interface | Medium | exactly
28 | `erc20-interface` | Check for wrong ERC20 interface | Medium | exactly
29 | `erc223-interface` | Check the wrong ERC223 interface | Medium | exactly
30 | `erc621-interface` | Check the wrong ERC621 interface | Medium | exactly
31 | `erc721-interface` | Check the wrong ERC721 interface | Medium | exactly
32 | `erc777-interface` | Check the wrong ERC777 interface | Medium | exactly
33 | `erc875-interface` | Check the wrong ERC875 interface | Medium | exactly
34 | `incorrect-equality` | Check the strict equality of danger | Medium | exactly
35 | `incorrect-signature` | Check for incorrect function signatures | Medium | exactly
36 | `locked-ether` | Whether the contract ether is locked | Medium | exactly
37 | `mapping-deletion` | Delete the mapped structure problem | Medium | exactly
38 | `shadowing-abstract` | State variables from the abstract contract | Medium | exactly
39 | `tautology` | Check for tautologies or contradictions | Medium | exactly
40 | `default-return-value` | Function returns only default value | Medium | probably
41 | `boolean-cst` | Check for misuse of Boolean constants | Medium | probably
42 | `constant-function-state` | Check Constant function to change state | Medium | probably
43 | `divide-before-multiply` | Imprecise order of arithmetic operations | Medium | probably
44 | `erc20-approve` | ERC-20 advance attack (TOD) | Medium | probably
45 | `function-problem` | Abnormal termination of contract function | Medium | probably
46 | `mul-var-len-arguments` | Hash collisions with multiple variable | Medium | probably
47 | `reentrancy-no-eth` | Re-entry vulnerabilities (no ether theft) | Medium | probably
48 | `reused-constructor` | Constructor conflict problem in the contract | Medium | probably
49 | `tx-origin` | Check the dangerous use of tx.origin | Medium | probably
50 | `typographical-error` | Check for writing errors (=+) | Medium | probably
51 | `unchecked-lowlevel` | Check for uncensored low-level calls | Medium | probably
52 | `unchecked-send` | Check unreviewed send | Medium | probably
53 | `uninitialized-local` | Check for uninitialized local variables | Medium | probably
54 | `unused-return` | Check if there is an unused return value | Medium | probably
55 | `writeto-arbitrarystorage` | It can be written to any storage location | Medium | probably
56 | `integer-overflow` | Check for integer overflow | Medium | probably
57 | `costly-loop` | Check for too expensive loops | Medium | possibly
58 | `shift-parameter-mixup` | Check reversible shift operation | Medium | possibly
59 | `shadowing-builtin` | Check the hiding of built-in symbols | Low | exactly
60 | `shadowing-function` | Check function hiding | Low | exactly
61 | `shadowing-local` | Check local variable hiding | Low | exactly
62 | `transfer-to-zeroaddress` | The withdrawal address is 0x0 | Low | exactly
63 | `uninitialized-fptr-cst` | Uninitialized pointers in constructor | Low | exactly
64 | `variable-scope` | Check the declaration of variables | Low | exactly
65 | `void-cst` | Calls to unimplemented constructors | Low | exactly
66 | `incorrect-modifier` | Restore abnormal Modifier | Low | exactly
67 | `assemblycall-rewrite` | Assemblycall covers the input | Low | probably
68 | `block-other-parameters` | Hazardous use variables (block.number etc.) | Low | probably
69 | `calls-loop` | Check the external call in the loop | Low | probably
70 | `events-access` | The loss of key access control parameters | Low | probably
71 | `events-maths` | The loss of key arithmetic parameters | Low | probably
72 | `extcodesize-invoke` | Check Extcodesize call | Low | probably
73 | `fllback-outofgas` | The fallback function is too complicated | Low | probably
74 | `incorrect-blockhash` | Incorrect use of Blockhash function | Low | probably
75 | `incorrect-inheritance-order` | The inherited variables conflict | Low | probably
76 | `missing-zero-check` | Check the use of zero addresses | Low | probably
77 | `reentrancy-benign` | Reentrant vulnerabilities (continuous calls) | Low | probably
78 | `reentrancy-events` | Reentrant vulnerabilities (events) | Low | probably
79 | `timestamp` | The dangerous use of block.timestamp | Low | probably
80 | `signature-malleability` | The signature contains an existing signature | Low | possibly
81 | `assembly` | Unsafe use of assembly | Info | exactly
82 | `assert-state-change` | Incorrect use of assert() | Info | exactly
83 | `delete-dynamic-arrays` | The deletion of the dynamic storage array | Info | exactly
84 | `deprecated-standards` | Solidity deprecated instructions | Info | exactly
85 | `erc20-indexed` | ERC20 event parameter is missing indexed | Info | exactly
86 | `erc20-throw` | ERC20 throws an exception | Info | exactly
87 | `length-manipulation` | Unsafe operation to check array length | Info | exactly
88 | `low-level-calls` | Check low-level calls | Info | exactly
89 | `msgvalue-equals-zero` | The judgment of msg.value and zero | Info | exactly
90 | `naming-convention` | The naming follows the Solidity format | Info | exactly
91 | `pragma` | Undeclared multiple compiled versions | Info | exactly
92 | `solc-version` | Check for incorrect Solidity version | Info | exactly
93 | `unimplemented-functions` | Functions overloaded in the contract | Info | exactly
94 | `upgrade-050` | Code for Solidity 0.5.x upgrade | Info | exactly
95 | `function-init-state` | State variables initialized by functions | Info | exactly
96 | `complex-function` | Check complex functions | Info | probably
97 | `hardcoded` | Check the legitimacy of the address | Info | probably
98 | `overpowered-role` | The permissions are too concentrated | Info | probably
99 | `reentrancy-limited-events` | Reentrancy vulnerabilities (limited events) | Info | probably
100 | `reentrancy-limited-gas` | Reentry (send and transfer, with eth) | Info | probably
101 | `reentrancy-limited-gas-no-eth` | Reentrance (send and transfer, no eth) | Info | probably
102 | `similar-names` | Detect similar variables | Info | probably
103 | `too-many-digits` | Too many number symbols | Info | probably
104 | `private-not-hidedata` | Check the use of private visibility | Info | possibly
105 | `safemath` | Check the use of SafeMath | Info | possibly
106 | `array-instead-bytes` | The byte array can be replaced with bytes | Opt | exactly
107 | `boolean-equal` | Check comparison with boolean constant | Opt | exactly
108 | `code-no-effects` | Check for invalid codes | Opt | exactly
109 | `constable-states` | State variables can be declared as constants | Opt | exactly
110 | `event-before-revert` | Check if event is called before revert | Opt | exactly
111 | `external-function` | Public functions can be declared as external | Opt | exactly
112 | `extra-gas-inloops` | Check for additional gas consumption | Opt | exactly
113 | `missing-inheritance` | Detect lost inheritance | Opt | exactly
114 | `redundant-statements` | Detect the use of invalid sentences | Opt | exactly
115 | `return-struct` | Multiple return values (struct) | Opt | exactly
116 | `revert-require` | Check Revert in if operation | Opt | exactly
117 | `send-transfer` | Check Transfe to replace Send | Opt | exactly
118 | `unused-state` | Check unused state variables | Opt | exactly
119 | `costly-operations-loop` | Expensive operations in the loop | Opt | probably


## How to install

SmartFast requires Python 3.6+ and [solc](https://github.com/ethereum/solidity/), the Solidity compiler.

### Using Git

```bash
git clone https://github.com/SmartContractTools/SmartFast.git && cd smartfast
python3 setup.py install
```

Of course, SmartFast can also be deployed in a virtual environment. This project provides a virtual environment by default, under the venv folder. Execute the following command to start the virtual operating environment.

```bash
source venv/bin/activate
```

If you want to recreate the virtual environment, perform the following operations.

```bash
virtualenv --python=/usr/bin/python3.7 venv
venv/bin/python setup.py install
pip install jpype1
pip install reportlab
pip install numpy
pip install pandas
pip install tqdm
pip install oscillo
```

## License

SmartFast is licensed and distributed under the AGPLv3 license.


## Publications

### References
- [ReJection: A AST-Based Reentrancy Vulnerability Detection Method](https://www.researchgate.net/publication/339354823_ReJection_A_AST-Based_Reentrancy_Vulnerability_Detection_Method), Rui Ma, Zefeng Jian, Guangyuan Chen, Ke Ma, Yujia Chen - CTCIS 19
- [Slither: A Static Analysis Framework For Smart Contracts](https://arxiv.org/abs/1908.09878), Josselin Feist, Gustavo Grieco, Alex Groce - WETSEB '19
- [ETHPLOIT: From Fuzzing to Efficient Exploit Generation against Smart Contracts](https://wcventure.github.io/FuzzingPaper/Paper/SANER20_ETHPLOIT.pdf), Qingzhao Zhang, Yizhuo Wang, Juanru Li, Siqi Ma - SANER 20
- [SmartCheck: Static Analysis of Ethereum Smart Contracts](https://orbilu.uni.lu/bitstream/10993/35862/3/smartcheck-paper.pdf), Sergei Tikhomirov, Ekaterina Voskresenskaya, Ivan Ivanitskiy, Ramil Takhaviev, Evgeny Marchenko, Yaroslav Alexandrov - WETSEB '18
