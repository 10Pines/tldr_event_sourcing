'use strict';

const program = require('commander');
const datapay = require('datapay');


program
.version('0.0.1')
.option('-h, --hash <hash>','hash to publish')
.option('-k, --private-key <privateKey>','wallet private key, used to publish the hash')
.parse(process.argv);

if(program.hash && program.privateKey) {
    let tx = {
        data: [program.hash],
        pay: { 
            key: program.privateKey,
            rpc: "https://api.bitindex.network"
         }
    };

    var output = {};

    //datapay.build(tx, function(err, tx) {
    //    console.log(tx.toString());
    //    console.log(tx.toObject());
    //});

    datapay.send(tx, function(err, res) {
        if(err) {
            output.err = err;
        }
        if(res) {
            output.transactionId = res;
        } 
        console.log(JSON.stringify(output));
    });

    //console.log(JSON.stringify({"transactionId": "sarasa"}));
}
else {
    console.error("need args!")
}


