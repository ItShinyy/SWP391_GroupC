/*
Purpose: payments.
Source: Refactored from Scriptos.sql (schema export).
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[payments](
	[id] [uniqueidentifier] NOT NULL,
	[invoice_id] [uniqueidentifier] NOT NULL,
	[payment_method] [varchar](20) NOT NULL,
	[amount] [decimal](18, 2) NOT NULL,
	[status] [varchar](20) NOT NULL,
	[txn_ref] [varchar](100) NOT NULL,
	[order_info] [nvarchar](255) NULL,
	[payment_url] [nvarchar](2048) NULL,
	[client_ip] [varchar](45) NULL,
	[expires_at] [datetime2](7) NULL,
	[vnp_transaction_no] [varchar](100) NULL,
	[vnp_bank_code] [varchar](30) NULL,
	[vnp_bank_tran_no] [varchar](100) NULL,
	[vnp_card_type] [varchar](30) NULL,
	[vnp_response_code] [varchar](10) NULL,
	[vnp_transaction_status] [varchar](10) NULL,
	[vnp_pay_date] [varchar](20) NULL,
	[signature_verified] [bit] NOT NULL,
	[callback_payload] [nvarchar](max) NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
	[processed_at] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

