# Contador de Produção Não-Intrusivo

## Identificação do Candidato

- **Nome completo:** Joaquim Pimentel Alves
- **GitHub:** [PimentaBR](https://github.com/PimentaBR)

## Visão Geral da Solução

O projeto conta peças em uma esteira usando um sensor LDR. Quando uma peça bloqueia a luz e depois sai da frente do sensor, o contador é incrementado.

O sistema também identifica quando o sensor permanece bloqueado por 5 segundos, tratando isso como uma micro-parada. Um botão permite zerar o contador no início de um novo turno.

## Arquitetura do Sistema Embarcado

O `main.py` executa um loop simples e não bloqueante para acompanhar o LDR e o botão.

- Luz normal: o sistema aguarda a passagem de uma peça.
- Luz bloqueada: o instante do bloqueio é armazenado.
- Luz normal novamente: uma peça é adicionada ao total.
- Bloqueio por 5 segundos: o alerta de micro-parada é enviado uma vez.
- Botão pressionado: o total e os temporizadores são zerados.

A temporização usa `ticks_ms()` e `ticks_diff()`. O único atraso do botão é de 50 ms para debounce.

## Componentes Utilizados na Simulação

- ESP32 DevKit C v4
- Sensor LDR `ldr1`
- Botão de reset `btn1`
- Monitor serial

### Ligações

| Componente | ESP32 |
|---|---|
| LDR VCC | 3V3 |
| LDR GND | GND |
| LDR DO | GPIO 34 |
| Botão | GPIO 27 e GND |

## Decisões Técnicas Relevantes

Foi utilizada a saída digital do LDR porque os testes trabalham com dois estados bem definidos: 800 lux para linha livre e 50 lux para luz bloqueada. Isso evita conversões analógicas desnecessárias.

A peça só é contada quando o sensor passa de bloqueado para livre. Dessa forma, uma mesma peça não é contada várias vezes enquanto permanece na frente do sensor.

As mensagens foram mantidas exatamente como os testes automatizados exigem.

## Resultados Obtidos

O projeto foi preparado para atender aos três cenários:

1. Contagem de uma peça após a sequência de 800, 50 e 800 lux.
2. Alerta quando o sensor fica em 50 lux por 5 segundos.
3. Reset do turno quando o botão é pressionado.

Mensagens utilizadas:

```text
Contador de Producao Inicializado
Peca detectada! Total: X
Alerta: Micro-parada detectada!
Turno resetado com sucesso. Contadores zerados.
```

## Execução Local

Depois de alterar o `src/main.py`, gere novamente o `fs.bin`:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\GERAR_FS_WINDOWS.ps1
```

Depois abra o `diagram.json` e inicie a simulação pelo Wokwi.
