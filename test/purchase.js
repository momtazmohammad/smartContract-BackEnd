const Purchase = artifacts.require("Purchase");

contract('Purchase', (accounts) => {
  let inst;
  let blc1,blc2,blc3;
  it('inst',async ()=>{
    inst=await Purchase.deployed();
  });
  it('should Create Enquery',async () => {    
    await inst.createEnquery(30,3,"10","screw","peac",4,"saipa","karaj","2000000000000000000","1000000000000000000","1000000000000000000",{from:accounts[7],value:"2000000000000000000"});
    //console.log("id:",id);
//    const cnt=await inst.getEnqueryCount.call();
  //  console.log(cnt.toNumber());
    await inst.placeBid(0,30,5000,"digikala",{from:accounts[8],value:"2000000000000000000"});
    blc1=await web3.eth.getBalance(accounts[7]);
    blc2=await web3.eth.getBalance(accounts[8]);
    blc3=await web3.eth.getBalance(accounts[9]);
    const enq=await inst.getEnquery(0);    
    const bid=await inst.getBid(0);
    console.log("enq:",enq,"bid:",bid);
    // const enq2=await inst.getEnquery2(0);    
    // console.log("enq2:",enq2);
    console.log("buyer:",blc1,"supplier1:",blc2,"supplier2:",blc3);      
    await inst.placeBid(0,30,4000,"digikala",{from:accounts[9],value:"2000000000000000000"});
    //let enq=await inst.getEnquery.call(0);
    //console.log("enq:",enq.enqno,"status:",enq.status,enq.supName,enq.buyerName,enq.enqEndTime);            
    //blc1=await web3.eth.getBalance(accounts[0]);
    //console.log("acc0:",blc);  
    blc1=await web3.eth.getBalance(accounts[7]);
    blc2=await web3.eth.getBalance(accounts[8]);
    blc3=await web3.eth.getBalance(accounts[9]);
    console.log("buyer:",blc1,"supplier1:",blc2,"supplier2:",blc3);    
  });  
  it('should End Enquery',async () => {    
    await setTimeout(()=>console.log("end"),10000);
    await inst.endEnquery(0,{from:accounts[7]});
    await inst.receivedItem(0,{from:accounts[7]});    
    blc1=await web3.eth.getBalance(accounts[7]);
    blc2=await web3.eth.getBalance(accounts[8]);
    blc3=await web3.eth.getBalance(accounts[9]);
    console.log("buyer:",blc1,"supplier1:",blc2,"supplier2:",blc3);  
    await inst.settlement(0,{from:accounts[9]});        
    blc1=await web3.eth.getBalance(accounts[7]);
    blc2=await web3.eth.getBalance(accounts[8]);
    blc3=await web3.eth.getBalance(accounts[9]);
    console.log("buyer:",blc1,"supplier1:",blc2,"supplier2:",blc3);       
  ;
    //   enq=await inst.getEnquery.call(0);
    // console.log("enq:",enq.enqno,"status:",enq.status,enq.enqEndTime,enq.blocktime);        
  });
});
