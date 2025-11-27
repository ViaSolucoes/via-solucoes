// lib/data/log_entry_extensions.dart

import 'package:flutter/material.dart';
import 'package:viasolucoes/models/log_entry.dart';

extension LogEntryUiExtensions on LogEntry {
  // ---------------------------------------------------------------------------
  // Rótulo amigável para mostrar na lista
  // ---------------------------------------------------------------------------
  String get actionLabel {
    switch (module) {
      case LogModule.contrato:
        switch (action) {
          case LogAction.created:
            return 'Contrato criado';
          case LogAction.updated:
            return 'Contrato atualizado';
          case LogAction.deleted:
            return 'Contrato excluído';
          case LogAction.viewed:
            return 'Contrato visualizado';
          case LogAction.statusChanged:
            return 'Status do contrato alterado';
          case LogAction.progressUpdated:
            return 'Progresso do contrato atualizado';
          case LogAction.fileUploaded:
            return 'Arquivo do contrato enviado';
          case LogAction.fileOpened:
            return 'Arquivo do contrato aberto';
          case LogAction.fileReplaced:
            return 'Arquivo do contrato substituído';
          case LogAction.fileRemoved:
            return 'Arquivo do contrato removido';
          default:
            return 'Ação de contrato';
        }

      case LogModule.tarefa:
        switch (action) {
          case LogAction.created:
            return 'Tarefa criada';
          case LogAction.updated:
            return 'Tarefa atualizada';
          case LogAction.completed:
            return 'Tarefa concluída';
          case LogAction.deleted:
            return 'Tarefa excluída';
          default:
            return 'Ação de tarefa';
        }

      case LogModule.usuario:
        switch (action) {
          case LogAction.login:
            return 'Login realizado';
          case LogAction.logout:
            return 'Logout realizado';
          case LogAction.updated:
            return 'Perfil atualizado';
          default:
            return 'Ação de usuário';
        }

      case LogModule.empresa:
        switch (action) {
          case LogAction.created:
            return 'Empresa cadastrada';
          case LogAction.updated:
            return 'Empresa atualizada';
          case LogAction.deleted:
            return 'Empresa excluída';
          default:
            return 'Ação em empresa';
        }

      case LogModule.storage:
        switch (action) {
          case LogAction.fileUploaded:
            return 'Arquivo enviado';
          case LogAction.fileOpened:
            return 'Arquivo aberto';
          case LogAction.fileReplaced:
            return 'Arquivo substituído';
          case LogAction.fileRemoved:
            return 'Arquivo removido';
          default:
            return 'Ação em arquivos';
        }

      case LogModule.sistema:
        switch (action) {
          case LogAction.error:
            return 'Erro registrado';
          default:
            return 'Ação do sistema';
        }
    }
  }

  // ---------------------------------------------------------------------------
  // Categoria para agrupamento
  // ---------------------------------------------------------------------------
  String get actionCategory {
    switch (module) {
      case LogModule.contrato:
        return 'Contrato';
      case LogModule.tarefa:
        return 'Tarefa';
      case LogModule.usuario:
        return 'Usuário';
      case LogModule.empresa:
        return 'Empresa';
      case LogModule.storage:
        return 'Arquivos';
      case LogModule.sistema:
        return 'Sistema';
    }
  }

  // ---------------------------------------------------------------------------
  // Cor padrão da ação
  // ---------------------------------------------------------------------------
  Color get actionColor {
    switch (module) {
      case LogModule.contrato:
        switch (action) {
          case LogAction.created:
            return Colors.blueAccent;
          case LogAction.updated:
          case LogAction.statusChanged:
          case LogAction.progressUpdated:
            return Colors.indigo;
          case LogAction.deleted:
            return Colors.redAccent;
          case LogAction.viewed:
            return Colors.grey;
          case LogAction.fileUploaded:
          case LogAction.fileOpened:
          case LogAction.fileReplaced:
          case LogAction.fileRemoved:
            return Colors.teal;
          default:
            return Colors.blueGrey;
        }

      case LogModule.tarefa:
        switch (action) {
          case LogAction.created:
            return Colors.green;
          case LogAction.updated:
            return Colors.lightBlue;
          case LogAction.completed:
            return Colors.greenAccent;
          case LogAction.deleted:
            return Colors.red;
          default:
            return Colors.green;
        }

      case LogModule.usuario:
        switch (action) {
          case LogAction.login:
            return Colors.blueGrey;
          case LogAction.logout:
            return Colors.brown;
          case LogAction.updated:
            return Colors.deepOrange;
          default:
            return Colors.blueGrey;
        }

      case LogModule.empresa:
        switch (action) {
          case LogAction.created:
            return Colors.deepPurple;
          case LogAction.updated:
            return Colors.purple;
          case LogAction.deleted:
            return Colors.red;
          default:
            return Colors.deepPurple;
        }

      case LogModule.storage:
        return Colors.teal;

      case LogModule.sistema:
        if (action == LogAction.error) return Colors.red;
        return Colors.grey;
    }
  }

  // ---------------------------------------------------------------------------
  // Ícone para usar na timeline/lista
  // ---------------------------------------------------------------------------
  IconData get actionIcon {
    switch (module) {
      case LogModule.contrato:
        switch (action) {
          case LogAction.created:
            return Icons.note_add_outlined;
          case LogAction.updated:
          case LogAction.statusChanged:
          case LogAction.progressUpdated:
            return Icons.edit_outlined;
          case LogAction.deleted:
            return Icons.delete_outline;
          case LogAction.viewed:
            return Icons.visibility_outlined;
          case LogAction.fileUploaded:
          case LogAction.fileReplaced:
          case LogAction.fileRemoved:
            return Icons.cloud_upload_outlined;
          case LogAction.fileOpened:
            return Icons.insert_drive_file_outlined;
          default:
            return Icons.description_outlined;
        }

      case LogModule.tarefa:
        switch (action) {
          case LogAction.created:
            return Icons.task_alt_outlined;
          case LogAction.updated:
            return Icons.edit_note_outlined;
          case LogAction.completed:
            return Icons.check_circle_outline;
          case LogAction.deleted:
            return Icons.delete_sweep_outlined;
          default:
            return Icons.task_outlined;
        }

      case LogModule.usuario:
        switch (action) {
          case LogAction.login:
            return Icons.login;
          case LogAction.logout:
            return Icons.logout;
          case LogAction.updated:
            return Icons.person_outline;
          default:
            return Icons.person;
        }

      case LogModule.empresa:
        return Icons.business_outlined;

      case LogModule.storage:
        return Icons.folder_outlined;

      case LogModule.sistema:
        if (action == LogAction.error) return Icons.error_outline;
        return Icons.settings_outlined;
    }
  }

  // ---------------------------------------------------------------------------
  // Descrição compacta (para lista)
  // ---------------------------------------------------------------------------
  String get compactDescription {
    if (description.length <= 120) return description;
    return '${description.substring(0, 117)}...';
  }
}
