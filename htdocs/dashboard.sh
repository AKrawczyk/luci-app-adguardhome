'use strict';
'require rpc';
'require view';


return view.extend({
    load_adguardhome_config: rpc.declare({
        object: 'luci.adguardhome',
        method: 'get_config'
    }),
    load_adguardhome_status: rpc.declare({
        object: 'luci.adguardhome',
        method: 'get_status'
    }),
    load_adguardhome_statistics: rpc.declare({
        object: 'luci.adguardhome',
        method: 'get_statistics'
    }),

    generic_failure: function(message) {
        return E('div', {'class': 'error'}, [_('RPC call failure: '), message])
    },
    urlmaker: function (host, port, tls_flag) {
        var proto = tls_flag ? 'https://' : 'http://';
        return proto + host + ':' + port + '/';
    },
    render_status_table: function (status, agh_config) {
        if (status.error) {
            return this.generic_failure(status.error)
        }
        // Take a hint from the base LuCI module for the Overview page,
        // declare the fields and use a loop to build the tabular status view.
        // Written out as key/value pairs, but it's just an iterable of elements.
        const weburl = this.urlmaker(agh_config.bind_host, status.http_port, agh_config.tls.enabled);
        const listen_addresses = L.isObject(status.dns_addresses) ? status.dns_addresses.join(', ') : _('Not found');
        const bootstrap_dns = L.isObject(agh_config.dns.bootstrap_dns) ? agh_config.dns.bootstrap_dns.join(', ') : _('Not found');
        const upstream_dns = L.isObject(agh_config.dns.upstream_dns) ? agh_config.dns.upstream_dns.join(', ') : _('Not found');
        const fields = [
            _('Running'), status.running ? _('Yes') : _('No'),
            _('Protection enabled'), status.protection_enabled ? _('Yes') : _('No'),
            _('Statistics period (days)'), agh_config.dns.statistics_interval,
            _('Web interface'), E('a', { 'href': weburl, 'target': '_blank' }, status.http_port),
            _('DNS listen port'), status.dns_port,
            _('DNS listen addresses'), listen_addresses,
            _('Bootstrap DNS addresses'), bootstrap_dns,
            _('Upstream DNS addresses'), upstream_dns,
            _('Version'), status.version,
        ];

        var table = E('table', { 'class': 'table', 'id': 'status' });
        for (var i = 0; i < fields.length; i += 2) {
            table.appendChild(E('tr', { 'class': 'tr' }, [
                E('td', { 'class': 'td left', 'width': '33%' }, [fields[i]]),
                E('td', { 'class': 'td left' }, [(fields[i + 1] != null) ? fields[i + 1] : _('Not found')])
            ]));
        }
        return table;
    },
    render_statistics_table: function (statistics) {
        // High level statistics
        if (statistics.error) {
            return this.generic_failure(statistics.error)
        }
        const fields = [
            _('DNS queries'), statistics.num_dns_queries,                                                                                        
            _('Blocked by filters'), statistics.num_blocked_filtering,                                                                           
            _('Enorced safe search'), statistics.num_replaced_safesearch,                                                                        
            _('Blocked malware/phishing'), statistics.num_replaced_safebrowsing,                                                                 
            _('Blocked adult websites'), statistics.num_replaced_parental,                                                                       
            _('Average processing time (seconds)'), statistics.avg_processing_time, 
        ];

        var table = E('table', { 'class': 'table', 'id': 'statistics' });
        for (var i = 0; i < fields.length; i += 2) {
            table.appendChild(
                E('tr', { 'class': 'tr' }, [
                    E('td', { 'class': 'td left', 'width': '33%' }, [fields[i]]),
                    E('td', { 'class': 'td left' }, [(fields[i + 1] != null) ? fields[i + 1] : _('Not found')])
                ]));
        }
        return table;
    },
    render_top_table: function(table_id, objects) {
        var table = E('table', { 'class': 'table', 'id': table_id });
        for (let i = 0; i < objects.length; i++) {
            table.appendChild(
                E('tr', { 'class': 'tr' }, [
                    E('td', { 'class': 'td left', 'width': '33%' }, Object.keys(objects[i])[0]),
                    E('td', { 'class': 'td left' }, Object.values(objects[i])[0])
                ])
            );
        }
        return table;
    },
    render_top_queries_table: function (statistics) {
        // Top 5 queried domains table view
        if (statistics.error) {
            return this.generic_failure(statistics.error)
        }
        const top_queries = statistics.top_queried_domains.slice(0, 5);
        return this.render_top_table('top_queries', top_queries)
    },
    render_top_blocked_table: function (statistics) {
        // Top 5 blocked domains table view
        if (statistics.error) {
            return this.generic_failure(statistics.error)
        }
        const top_blocked = statistics.top_blocked_domains.slice(0, 5);
        return this.render_top_table('top_blocked', top_blocked)
    },
    // Helper to render a bar-style sparkline for 24-hour data, with hour labels and tooltips
    render_bar_sparkline: function(data, color) {
        if (!Array.isArray(data) || data.length !== 24) return null;
        const max = Math.max(...data, 1);
        const now = new Date();
        const currentHour = now.getHours();
        // Generate hour labels: first is 24h ago, last is current hour
        const hourLabels = Array.from({length: 24}, (_, i) => (currentHour - 23 + i + 24) % 24);
        return E('div', { class: 'dashboard-bar-sparkline' },
            data.map((v, i) =>
                E('div', { class: 'dashboard-bar-col' }, [
                    E('div', {
                        class: 'dashboard-bar',
                        style: `height: ${(v / max) * 28 + 2}px; background:${color};`,
                        title: v
                    }),
                    E('div', { class: 'dashboard-bar-label' }, hourLabels[i])
                ])
            )
        );
    },
    render_summary_cards: function(statistics) {
        // Hour labels starting at 18
        const hourLabels = Array.from({length: 24}, (_, i) => (i + 18) % 24);
        // Four summary cards at the top, now with bar sparklines
        const cards = [
            {
                title: _('DNS Queries'),
                value: statistics.num_dns_queries,
                subtitle: '',
                colorClass: 'card-blue',
                data: statistics.dns_queries,
                color: '#3498db'
            },
            {
                title: _('Blocked by Filters'),
                value: statistics.num_blocked_filtering,
                subtitle: statistics.num_dns_queries > 0 ? ((statistics.num_blocked_filtering / statistics.num_dns_queries * 100).toFixed(0) + '%') : '0%',
                colorClass: 'card-red',
                data: statistics.blocked_filtering,
                color: '#e74c3c'
            },
            {
                title: _('Blocked malware/phishing'),
                value: statistics.num_replaced_safebrowsing,
                subtitle: statistics.num_dns_queries > 0 ? ((statistics.num_replaced_safebrowsing / statistics.num_dns_queries * 100).toFixed(0) + '%') : '0%',
                colorClass: 'card-green',
                data: statistics.replaced_safebrowsing,
                color: '#27ae60'
            },
            {
                title: _('Blocked adult websites'),
                value: statistics.num_replaced_parental,
                subtitle: statistics.num_dns_queries > 0 ? ((statistics.num_replaced_parental / statistics.num_dns_queries * 100).toFixed(0) + '%') : '0%',
                colorClass: 'card-yellow',
                data: statistics.replaced_parental,
                color: '#f1c40f'
            }
        ];
        return E('div', { 'class': 'dashboard-grid dashboard-cards' },
            cards.map(card =>
                E('div', { 'class': 'dashboard-card ' + card.colorClass }, [
                    E('div', { 'class': 'dashboard-card-value' }, card.value),
                    E('div', { 'class': 'dashboard-card-title' }, card.title),
                    card.subtitle ? E('div', { 'class': 'dashboard-card-subtitle' }, card.subtitle) : null,
                    this.render_bar_sparkline(card.data, card.color)
                ])
            )
        );
    },
    render_top_clients_table: function(statistics) {
        if (statistics.error) {
            return this.generic_failure(statistics.error)
        }
        const top_clients = statistics.top_clients.slice(0, 5);
        var table = E('table', { 'class': 'dashboard-table', 'id': 'top_clients' });
        table.appendChild(E('tr', {}, [
            E('th', {}, _('Client')),
            E('th', {}, _('Requests count'))
        ]));
        for (var i = 0; i < top_clients.length; i++) {
            const client = Object.keys(top_clients[i])[0];
            const count = Object.values(top_clients[i])[0];
            const percent = statistics.num_dns_queries > 0 ? ((count / statistics.num_dns_queries * 100).toFixed(2) + '%') : '';
            table.appendChild(E('tr', {}, [
                E('td', {}, client),
                E('td', {}, [count + (percent ? ' (' + percent + ')' : '')])
            ]));
        }
        return table;
    },
    // Core LuCI functions from here on.
    load: function () {
        return Promise.all([
            this.load_adguardhome_status(),
            this.load_adguardhome_statistics(),
            this.load_adguardhome_config()
        ]);
    },
    render: function (data) {
        var status = data[0] || {};
        var statistics = data[1] || {};
        var agh_config = data[2] || {};

        if (status.auth_error) {
            return E('div', { 'class': 'cbi-map', 'id': 'map' }, [
                E('div', { 'class': 'cbi-section' }, [
                    E('div', { 'class': 'left' }, [
                        E('h3', _('AdGuard Home Status - Error')),
                        E('div', { 'class': 'error' }, status.auth_error),
                        E('div', { 'class': 'info' }, _('Please open the Configuration section, and provide the credentials.'))
                    ])
                ]),
            ]);
        }

        // Dashboard layout
        return E('div', { 'class': 'cbi-map', 'id': 'map' }, [
            // Summary cards row
            this.render_summary_cards(statistics),
            // Main grid
            E('div', { 'class': 'dashboard-grid dashboard-main' }, [
                // General statistics table
                E('div', { 'class': 'dashboard-section' }, [
                    E('h3', _('General statistics')),
                    this.render_statistics_table(statistics)
                ]),
                // Top clients table
                E('div', { 'class': 'dashboard-section' }, [
                    E('h3', _('Top clients')), 
                    this.render_top_clients_table(statistics)
                ]),
                // Top queried domains table
                E('div', { 'class': 'dashboard-section' }, [
                    E('h3', _('Top queried domains')),
                    this.render_top_queries_table(statistics)
                ]),
                // Top blocked domains table
                E('div', { 'class': 'dashboard-section' }, [
                    E('h3', _('Top blocked domains')),
                    this.render_top_blocked_table(statistics)
                ])
            ])
        ]);
    },
    handleSave: null,
    handleSaveApply: null,
    handleReset: null
})
