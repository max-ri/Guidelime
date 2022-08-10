# Lib: HereBeDragons

## [2.08-release-4-gc32dc23](https://github.com/Nevcairiel/HereBeDragons/tree/c32dc2388d6be8ebb6913a3db750c2e655d80733) (2022-08-09)
[Full Changelog](https://github.com/Nevcairiel/HereBeDragons/compare/2.08-release...c32dc2388d6be8ebb6913a3db750c2e655d80733) [Previous Releases](https://github.com/Nevcairiel/HereBeDragons/releases)

- Move DK starting area override into transforms  
    The instance ID overrides were meant for dynamic phasing, not  
    permanently instanced zones, which the transform was designed for  
    instead, even if the map coordinates are not transformed.  
    This should make the behavior more consistent for users.  
- Don't use expansion level checks, they may not be present in all clients  
- Fix handling of pins from phased sub maps  
- Add Wrath Classic support  
