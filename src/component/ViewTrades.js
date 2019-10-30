import React, { Component } from 'react';
import { Table } from 'react-bootstrap';

import brokerJson from '../data/BrokerTrade.json'

class ViewTrades extends Component {

    constructor(props) {
        super(props);
        this.state = {
            trades: brokerJson.trades
        };
        

    }

    render() {
        return (
            <div>
                {this.showTrades()}
            </div>
        );
    }

    showTrades() {       
        // this.setState({trades:brokerJson})
        return (
            <div>
                //check for trades array lenght

                <Table striped bordered hover>
                    <thead>
                        <tr>
                            <th>Trade Id</th>
                            <th>Trade date</th>
                            <th>Currency</th>
                            <th>Settlement date</th>
                            <th>Brokerage</th>
                            <th>Status</th>
                            <th>Settlement reference</th>
                        </tr>
                    </thead>
                    <tbody>
                        {
                            this.state.trades.map(brokerTrade => {
                                return (
                                    <tr>
                                        <td>{brokerTrade.trade.markitWireId}</td>
                                        <td>{brokerTrade.trade.tradeDate}</td>
                                        <td>{brokerTrade.trade.currency}</td>
                                        <td>{brokerTrade.trade.settlementDate}</td>
                                        <td>{brokerTrade.trade.brokerageAmount}</td>
                                        <td>{brokerTrade.status}</td>
                                        <td>{brokerTrade.paymentReference}</td>
                                    </tr>
                                )
                            })
                        }
                    </tbody>
                </Table>
            </div>
        )
    }


}



export default ViewTrades;