// module.exports = nuguReq;
const uuid = require('uuid').v4;
const _ = require('lodash');
const { DOMAIN } = require('../config');
const axios = require('axios');
const express = require('express');
const app = express();

const SERVER_URL = 'http://localhost'; // 서버 주소를 변수로 선언
const PORT_3001 = '3001'; // 포트 3001을 변수로 선언
const PORT_4000 = '4000'; // 포트 4000을 변수로 선언

app.use(express.json());

class NPKRequest {
  constructor(httpReq) {
    this.context = httpReq.body.context;
    this.action = httpReq.body.action;
    console.log(`[Received NUGU Request] Context: ${JSON.stringify(this.context)}, Action: ${JSON.stringify(this.action)}`);
  }

  async do(npkResponse) {
    await this.actionRequest(npkResponse);
  }

  async actionRequest(npkResponse) {
    const actionName = this.action.actionName;

    switch (actionName) {
      case 'Register_Data': {
        const yearVal = this.action.parameters.year_val ? this.action.parameters.year_val.value : null;
        const monthVal = this.action.parameters.month_val ? this.action.parameters.month_val.value : null;
        const dayVal = this.action.parameters.day_val ? this.action.parameters.day_val.value : null;
        const doVal = this.action.parameters.do_val ? this.action.parameters.do_val.value : null;

        const formattedDate = `${yearVal}-${String(monthVal).padStart(2, '0')}-${String(dayVal).padStart(2, '0')}`;

        console.log(`Register_Data action triggered with parameters: Date: ${formattedDate}, Do: ${doVal}`);

        const messagePayload = JSON.stringify({
          "shared calendar event": [formattedDate, doVal]
        });

        console.log('Preparing to send shared calendar event data to backend:', messagePayload);

        axios.post(`${SERVER_URL}:${PORT_4000}/send-message`, { message: messagePayload }, {
          headers: {
            "Content-Type": "application/json"
          }
        })
          .then(response => console.log('Data sent to backend server:', response.data))
          .catch(error => console.error('Error sending data to backend server:', error))

        npkResponse.setOutputParameters({ year: yearVal, month: monthVal, day: dayVal, do: doVal });
        break;
      }

      case 'Reading_Text': {
        await axios.get(`${SERVER_URL}:${PORT_3001}/latest-greeting`)
          .then(response => {
            const greetingMessage = response.data;
            console.log('Fetched latest greeting message:', greetingMessage);
            npkResponse.setOutputParameters({greeting_message: greetingMessage});
          })
          .catch(error => {
            console.error('Error fetching latest greeting message:', error);
            npkResponse.setOutputParameters({ error: "Error fetching latest greeting message" });
          });
        break;
      }

      case 'ProductNameAction': {
        const productName = this.action.parameters.product_name.value;
        console.log('Output parameters for ProductNameAction:', { name: productName });
        npkResponse.setOutputParameters({ name: productName });
        console.log(`Sending to server: ${JSON.stringify({ name: productName })}`);

        axios.post(`${SERVER_URL}:${PORT_4000}/wishlist`, JSON.stringify({ name: productName }), {
          headers: {
            "Content-Type": "application/json"
          }
        })
          .then(response => console.log('Data sent to server:', response.data))
          .catch(error => console.error('Error sending data to server:', error));
        break;
      }

      default:
        console.log(`Unhandled action: ${actionName}`);
        npkResponse.setOutputParameters({ error: "Unhandled action" });
        break;
    }
  }
}

class NPKResponse {
  constructor() {
    this.version = '2.0';
    this.resultCode = 'OK';
    this.output = {};
    this.directives = [];
  }

  setOutputParameters(output) {
    this.output = output;
    console.log(`[NUGU Response Output] ${JSON.stringify(this.output)}`);
  }
}

const nuguReq = function (httpReq, httpRes, next) {
  let npkResponse = new NPKResponse();
  let npkRequest = new NPKRequest(httpReq);
  npkRequest.do(npkResponse)
    .then(() => {
      console.log(`[Sending NUGU Response] ${JSON.stringify(npkResponse)}`);
      return httpRes.send(npkResponse);
    });
};

module.exports = nuguReq;
